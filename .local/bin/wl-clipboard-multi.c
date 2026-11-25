/*
 * wl-clipboard-multi —— 一个 Wayland 剪贴板 owner，同时 offer 多个 MIME 类型。
 *
 * 背景：wl-copy 每次只能 offer 一个 MIME，但不同程序认不同类型：
 *   - Thunar / Nautilus（GTK 文件管理器）→ x-special/gnome-copied-files
 *   - VSCode / Firefox（Electron、浏览器）→ text/uri-list
 * Wayland 协议本身允许一个 data_source offer 多个类型，由 paste 方按需取用。
 * 这个小程序就是补上 wl-copy 缺的这一能力。
 *
 * 用法： wl-clipboard-multi <gnome-copied-files 文件> <uri-list 文件>
 * 常驻直到剪贴板被别的程序抢占（收到 cancelled 事件）后自行退出。
 *
 * 编译： gcc -O2 -o wl-clipboard-multi wl-clipboard-multi.c -lwayland-client
 */
#define _GNU_SOURCE
#include <wayland-client.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <errno.h>

#define MAX_CONTENT (1 << 20)   /* 1 MiB，足够几千个文件路径 */

static struct wl_display           *display;
static struct wl_data_device_manager *dnd_manager;
static struct wl_seat              *seat;
static struct wl_data_device       *data_device;
static struct wl_data_source       *data_source;

static char   gnome_data[MAX_CONTENT];
static size_t gnome_len;
static char   uri_data[MAX_CONTENT];
static size_t uri_len;

/* paste 方请求某个 MIME 时，按类型吐出对应内容 */
static void source_send(void *data, struct wl_data_source *src,
                        const char *mime, int fd)
{
    const char *buf;
    size_t len;

    if (strcmp(mime, "x-special/gnome-copied-files") == 0) {
        buf = gnome_data; len = gnome_len;
    } else if (strcmp(mime, "text/uri-list") == 0) {
        buf = uri_data;   len = uri_len;
    } else {
        /* text/plain、UTF8_STRING 等兜底给纯 URI 列表 */
        buf = uri_data; len = uri_len;
    }

    if (len) {
        ssize_t n = write(fd, buf, len);
        (void)n;
    }
    close(fd);
}

static void source_target(void *data, struct wl_data_source *src, const char *mime) {}
static void source_cancelled(void *data, struct wl_data_source *src)
{
#ifdef WLOG
    FILE *f = fopen("/home/keer/wlcm-debug.log", "a");
    if (f) { fputs("cancelled\n", f); fclose(f); }
#endif
    exit(0);
}
static void source_dnd_drop_performed(void *data, struct wl_data_source *src) {}
static void source_dnd_finished(void *data, struct wl_data_source *src) {}
static void source_action(void *data, struct wl_data_source *src, uint32_t action) {}

static const struct wl_data_source_listener source_listener = {
    .target             = source_target,
    .send               = source_send,
    .cancelled          = source_cancelled,
    .dnd_drop_performed = source_dnd_drop_performed,
    .dnd_finished       = source_dnd_finished,
    .action             = source_action,
};

static void registry_global(void *data, struct wl_registry *reg,
                            uint32_t name, const char *iface, uint32_t version)
{
    if (strcmp(iface, "wl_data_device_manager") == 0) {
        dnd_manager = wl_registry_bind(reg, name,
                        &wl_data_device_manager_interface, 3);
    } else if (strcmp(iface, "wl_seat") == 0) {
        seat = wl_registry_bind(reg, name, &wl_seat_interface,
                                version < 7 ? version : 7);
    }
}

static void registry_global_remove(void *data, struct wl_registry *reg, uint32_t name) {}

static const struct wl_registry_listener registry_listener = {
    .global        = registry_global,
    .global_remove = registry_global_remove,
};

static size_t slurp(const char *path, char *buf)
{
    FILE *f = fopen(path, "rb");
    if (!f) return 0;
    size_t n = fread(buf, 1, MAX_CONTENT - 1, f);
    fclose(f);
    buf[n] = '\0';
    return n;
}

/* 变成真正的 daemon：脱离控制终端、脱离调用者的进程组/session，
 * 否则调用它的 shell 退出时（尤其在受限沙箱里）会被一起回收。 */
static void daemonize(void)
{
    pid_t pid = fork();
    if (pid < 0)  exit(1);
    if (pid > 0)  _exit(0);      /* 父进程立即返回，让调用者不等 */

    if (setsid() < 0) exit(1);   /* 脱离终端与进程组 */
    if (chdir("/") < 0) {}       /* 不占用调用者的工作目录 */

    /* 关闭继承来的 fd，避免占着 pipe 让调用者的 shell 一直等 */
    int devnull = open("/dev/null", O_RDWR);
    if (devnull >= 0) {
        dup2(devnull, STDIN_FILENO);
        dup2(devnull, STDOUT_FILENO);
        dup2(devnull, STDERR_FILENO);
        if (devnull > STDERR_FILENO) close(devnull);
    }
}

int main(int argc, char **argv)
{
    if (argc != 3) {
        fprintf(stderr,
                "用法: %s <gnome-copied-files 文件> <uri-list 文件>\n", argv[0]);
        return 2;
    }

    /* 先把输入读进内存，再 daemonize —— daemon 后不再依赖这两个文件 */
    gnome_len = slurp(argv[1], gnome_data);
    uri_len   = slurp(argv[2], uri_data);
    if (!gnome_len && !uri_len) {
        fprintf(stderr, "两个输入文件都为空\n");
        return 1;
    }

    daemonize();

    display = wl_display_connect(NULL);
    if (!display) {
        fprintf(stderr, "无法连接 Wayland display\n");
        return 1;
    }

    struct wl_registry *reg = wl_display_get_registry(display);
    wl_registry_add_listener(reg, &registry_listener, NULL);
    wl_display_roundtrip(display);

    if (!dnd_manager || !seat) {
        fprintf(stderr, "缺少 wl_data_device_manager 或 wl_seat\n");
        return 1;
    }

    data_device = wl_data_device_manager_get_data_device(dnd_manager, seat);
    data_source = wl_data_device_manager_create_data_source(dnd_manager);
    wl_data_source_add_listener(data_source, &source_listener, NULL);

    if (gnome_len) wl_data_source_offer(data_source, "x-special/gnome-copied-files");
    if (uri_len)   wl_data_source_offer(data_source, "text/uri-list");
    wl_data_source_offer(data_source, "text/plain");
    wl_data_source_offer(data_source, "UTF8_STRING");

    /* serial=0：wl-copy 也这么做，Hyprland 等 compositor 不校验该值 */
    wl_data_device_set_selection(data_device, data_source, 0);
    wl_display_roundtrip(display);

    /* 常驻服务 paste 请求；被抢占时 cancelled 回调里 exit(0) */
    int rc;
    while ((rc = wl_display_dispatch(display)) >= 0) {
#ifdef WLOG
        FILE *f = fopen("/home/keer/wlcm-debug.log", "a");
        if (f) { fprintf(f, "dispatch=%d\n", rc); fclose(f); }
#endif
    }
#ifdef WLOG
    {
        FILE *f = fopen("/home/keer/wlcm-debug.log", "a");
        if (f) { fprintf(f, "dispatch ended rc=%d errno=%d\n", rc, errno); fclose(f); }
    }
#endif

    return 0;
}
