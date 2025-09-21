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
#### 隐藏标题栏
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
