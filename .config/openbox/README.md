# Openbox

## Install
> openbox obconf lxappearance tint2 obmenu3 obmenu-generator

> network-manager-applet nitrogen picom xrandr dunst libnotify notify-send xautolock ktqt-policykit gnome-keyring seahorse i3lock-color

## volume
```sh
chmod +x scripts/volume.sh
```
### rofi
themes: [rofi-themes-collection](https://github.com/newmanls/rofi-themes-collection)

Run `rofi -show drun -show-icons` --> `Role Theme Selector` to choose a theme, then press `Alt + a` to use it.

## Reset configuration
```sh
openbox --reconfigure
obmenu-generator -s -c
```
## tint2

- [themes](https://github.com/addy-dclxvi/tint2-theme-collections)

## 其他配置
### 隐藏标题栏
`~/.config/openbox/rc.xml`:
```xml
<applications>
    <application class="firefox">
      <decor>no</decor>
    </application>
     
    <application class="Emamcs">
      <decor>no</decor>
    </application>

    <application class="...">
      <decor>no</decor>
    </application>
</applications>
```
如果想要知道某个程序的CLASS具体是什么，可以输入如下命令，然后鼠标点击程序窗口，就有CLASS的反馈了：

```sh
obxprop | grep 'CLASS'
```
比如：
```sh
~ obxprop | grep 'CLASS'
_OB_APP_GROUP_CLASS(UTF8_STRING) = "Firefox"
_OB_APP_CLASS(UTF8_STRING) = "firefox"
WM_CLASS(STRING) = "Navigator", "firefox"
```
### 触摸板
1. 确认你的触摸板驱动
```sh
sudo pacman -S xorg-xinput
```
通过如下命令找到你的触摸板设备（通常名为 “TouchPad” 或 “Touchpad”），并记下其 `id` 或全名。
```sh
xinput list
```
```sh
xinput list-props [你的触摸板id或名称]
```
在输出中，如果看到很多以 “libinput” 开头的属性，说明你正在使用 libinput 驱动。

2. 创建 Xorg 配置文件
`sudo vim /etc/X11/xorg.conf.d/70-touchpad.conf`

```
Section "InputClass"
        Identifier "touchpad"
        MatchIsTouchpad "on"
        Driver "libinput"
        
        # 启用自然滚动（反向滚动）
        Option "NaturalScrolling" "true"
        
        # 禁用触摸板当外接鼠标插入时
        Option "DisableWhileTyping" "true"
        
        # 启用点击（Tap-to-click）
        Option "Tapping" "true"
        
        # 启用双指滚动（Two-finger scrolling）
        Option "ScrollMethod" "two-finger"
        
        # 启用中键点击（用三指同时点击模拟中键）
        # Option "MiddleEmulation" "true"
        
        # 设置点击力度（压力感应，如果点击不灵敏可以调整）
        # Option "TapPressure" "30"
EndSection
```
重启电脑就生效了。

3. 临时测试和调整（使用 `xinput`）

如果你想临时测试某个设置，而不是创建永久配置文件，可以使用 xinput 命令。

例如，你想先测试一下自然滚动：
```
# 找到触摸板的 ID
xinput list

# 设置自然滚动（将 [id] 替换为你的触摸板 ID）
xinput set-prop [id] "libinput Natural Scrolling Enabled" 1

# 禁用触摸板
xinput disable [id]

# 重新启用触摸板
xinput enable [id]

```
这种方式的好处是即时生效，但缺点是重启后设置会丢失。适合用来测试哪些配置适合你。
