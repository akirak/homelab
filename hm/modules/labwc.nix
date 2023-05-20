{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.wayland.windowManager.labwc;
in {
  options = {
    wayland.windowManager.labwc = {
      enable = lib.mkEnableOption (lib.mdDoc "Enable labwc Wayland compositor");
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [
      pkgs.labwc
    ];

    # Based on https://raw.githubusercontent.com/labwc/labwc/master/docs/rc.xml.all
    xdg.configFile."labwc/rc.xml".text = ''
      <?xml version="1.0"?>

      <!--
        This file contains all supported config elements & attributes with
        default values.
      -->

      <labwc_config>

        <core>
          <decoration>server</decoration>
          <gap>0</gap>
          <adaptiveSync>no</adaptiveSync>
          <reuseOutputMode>no</reuseOutputMode>
        </core>

        <!-- <font><theme> can be defined without an attribute to set all places -->
        <theme>
          <name></name>
          <cornerRadius>8</cornerRadius>
          <font place="ActiveWindow">
            <name>sans</name>
            <size>10</size>
            <slant>normal</slant>
            <weight>normal</weight>
          </font>
          <font place="MenuItem">
            <name>sans</name>
            <size>10</size>
            <slant>normal</slant>
            <weight>normal</weight>
          </font>
          <font place="OnScreenDisplay">
            <name>sans</name>
            <size>10</size>
            <slant>normal</slant>
            <weight>normal</weight>
          </font>
        </theme>

        <windowSwitcher show="yes" preview="yes" outlines="yes">
          <fields>
            <field content="type" width="25%" />
            <field content="app_id" width="25%" />
            <field content="title" width="50%" />
          </fields>
        </windowSwitcher>

        <!-- edge strength is in pixels -->
        <resistance>
          <screenEdgeStrength>20</screenEdgeStrength>
        </resistance>

        <focus>
          <followMouse>no</followMouse>
          <followMouseRequiresMovement>yes</followMouseRequiresMovement>
          <raiseOnFocus>no</raiseOnFocus>
        </focus>

        <!-- Set range to 0 to disable window snapping completely -->
        <snapping>
          <range>1</range>
          <topMaximize>yes</topMaximize>
        </snapping>

        <!--
          Use GoToDesktop left | right to switch workspaces.
          Use SendToDesktop left | right to move windows.
          See man labwc-actions for further information.

          Workspaces can be configured like this:
          <desktops>
            <popupTime>1000</popupTime>
            <names>
              <name>Workspace 1</name>
              <name>Workspace 2</name>
              <name>Workspace 3</name>
            </names>
          </desktops>
        -->
        <desktops>
          <!--
            popupTime defaults to 1000 so could be left out.
            Set to 0 to completely disable the workspace OSD.
          -->
          <popupTime>1000</popupTime>
          <names>
            <name>Default</name>
          </names>
        </desktops>

        <!-- Percent based regions based on output usable area, % char is required -->
        <!--
          <regions>
            <region name="top-left"     x="0%"  y="0%"  height="50%"  width="50%"  />
            <region name="top"          x="0%"  y="0%"  height="50%"  width="100%" />
            <region name="top-right"    x="50%" y="0%"  height="50%"  width="50%"  />
            <region name="left"         x="0%"  y="0%"  height="100%" width="50%"  />
            <region name="center"       x="10%" y="10%" height="80%"  width="80%"  />
            <region name="right"        x="50%" y="0%"  height="100%" width="50%"  />
            <region name="bottom-left"  x="0%"  y="50%" height="50%"  width="50%"  />
            <region name="bottom"       x="0%"  y="50%" height="50%"  width="100%" />
            <region name="bottom-right" x="50%" y="50%" height="50%"  width="50%"  />
          </regions>
        -->

        <!--
          Keybind actions are specified in labwc-actions(5)
          The following keybind modifiers are supported:
            W - window/super/logo
            A - alt
            C - ctrl
            S - shift

          Use <keyboard><default /> to load all the default keybinds (those listed
          below). If the default keybinds are largely what you want, a sensible
          approach could be to start the <keyboard> section with a <default />
          element, and then (re-)define any special binds you need such as launching
          your favourite terminal or application launcher. See rc.xml for an example.
        -->
        <keyboard>
          <repeatRate>25</repeatRate>
          <repeatDelay>600</repeatDelay>
          <keybind key="A-Tab">
            <action name="NextWindow" />
          </keybind>
          <keybind key="W-Return">
            <action name="Execute" command="foot" />
          </keybind>
          <keybind key="W-Space">
            <action name="Execute" command="fuzzel" />
          </keybind>
          <keybind key="A-F4">
            <action name="Close" />
          </keybind>
          <keybind key="W-a">
            <action name="ToggleMaximize" />
          </keybind>
          <keybind key="A-Left">
            <action name="MoveToEdge" direction="left" />
          </keybind>
          <keybind key="A-Right">
            <action name="MoveToEdge" direction="right" />
          </keybind>
          <keybind key="A-Up">
            <action name="MoveToEdge" direction="up" />
          </keybind>
          <keybind key="A-Down">
            <action name="MoveToEdge" direction="down" />
          </keybind>
          <keybind key="W-Left">
            <action name="SnapToEdge" direction="left" />
          </keybind>
          <keybind key="W-Right">
            <action name="SnapToEdge" direction="right" />
          </keybind>
          <keybind key="W-Up">
            <action name="SnapToEdge" direction="up" />
          </keybind>
          <keybind key="W-Down">
            <action name="SnapToEdge" direction="down" />
          </keybind>
          <keybind key="A-Space">
            <action name="ShowMenu" menu="client-menu" />
          </keybind>
          <keybind key="XF86_AudioLowerVolume">
            <action name="Execute" command="amixer sset Master 5%-" />
          </keybind>
          <keybind key="XF86_AudioRaiseVolume">
            <action name="Execute" command="amixer sset Master 5%+" />
          </keybind>
          <keybind key="XF86_AudioMute">
            <action name="Execute" command="amixer sset Master toggle" />
          </keybind>
          <keybind key="XF86_MonBrightnessUp">
            <action name="Execute" command="brightnessctl set +10%" />
          </keybind>
          <keybind key="XF86_MonBrightnessDown">
            <action name="Execute" command="brightnessctl set 10%-" />
          </keybind>
          <!-- SnapToRegion via W-Numpad -->
          <!--
          <keybind key="W-KP_7"><action name="SnapToRegion" region="top-left" /></keybind>
          <keybind key="W-KP_8"><action name="SnapToRegion" region="top" /></keybind>
          <keybind key="W-KP_9"><action name="SnapToRegion" region="top-right" /></keybind>
          <keybind key="W-KP_4"><action name="SnapToRegion" region="left" /></keybind>
          <keybind key="W-KP_5"><action name="SnapToRegion" region="center" /></keybind>
          <keybind key="W-KP_6"><action name="SnapToRegion" region="right" /></keybind>
          <keybind key="W-KP_1"><action name="SnapToRegion" region="bottom-left" /></keybind>
          <keybind key="W-KP_2"><action name="SnapToRegion" region="bottom" /></keybind>
          <keybind key="W-KP_3"><action name="SnapToRegion" region="bottom-right" /></keybind>
          -->
        </keyboard>

        <!--
          Multiple <mousebind> can exist within one <context>
          Multiple <actions> can exist within one <mousebind>
          Currently, the only openbox-action not supported is "Unshade"

          Use <mouse><default /> to load all the default mousebinds (those listed
          below). If the default mousebinds are largely what you want, a sensible
          approach could be to start the <mouse> section with a <default />
          element, and then (re-)define any special binds you need such as launching
          a custom menu when right-clicking on your desktop. See rc.xml for an example.
        -->
        <mouse>

          <!-- time is in ms -->
          <doubleClickTime>500</doubleClickTime>
          <scrollFactor>1.0</scrollFactor>

          <context name="Frame">
            <mousebind button="A-Left" action="Press">
              <action name="Focus" />
              <action name="Raise" />
            </mousebind>
            <mousebind button="A-Left" action="Drag">
              <action name="Move" />
            </mousebind>
            <mousebind button="A-Right" action="Press">
              <action name="Focus" />
              <action name="Raise" />
            </mousebind>
            <mousebind button="A-Right" action="Drag">
              <action name="Resize" />
            </mousebind>
          </context>

          <context name="Top">
            <mousebind button="Left" action="Drag">
              <action name="Resize" />
            </mousebind>
          </context>
          <context name="Left">
            <mousebind button="Left" action="Drag">
              <action name="Resize" />
            </mousebind>
          </context>
          <context name="Right">
            <mousebind button="Left" action="Drag">
              <action name="Resize" />
            </mousebind>
          </context>
          <context name="Bottom">
            <mousebind button="Left" action="Drag">
              <action name="Resize" />
            </mousebind>
          </context>
          <context name="TRCorner">
            <mousebind button="Left" action="Drag">
              <action name="Resize" />
            </mousebind>
          </context>
          <context name="BRCorner">
            <mousebind button="Left" action="Drag">
              <action name="Resize" />
            </mousebind>
          </context>
          <context name="TLCorner">
            <mousebind button="Left" action="Drag">
              <action name="Resize" />
            </mousebind>
          </context>
          <context name="BLCorner">
            <mousebind button="Left" action="Drag">
              <action name="Resize" />
            </mousebind>
          </context>

          <context name="TitleBar">
            <mousebind button="Left" action="Press">
              <action name="Focus" />
              <action name="Raise" />
            </mousebind>
            <mousebind button="Right" action="Click">
              <action name="Focus" />
              <action name="Raise" />
              <action name="ShowMenu" menu="client-menu" />
            </mousebind>
          </context>

          <context name="Title">
            <mousebind button="Left" action="Drag">
              <action name="Move" />
            </mousebind>
            <mousebind button="Left" action="DoubleClick">
              <action name="ToggleMaximize" />
            </mousebind>
          </context>

          <context name="Maximize">
            <mousebind button="Left" action="Click">
              <action name="Focus" />
              <action name="Raise" />
              <action name="ToggleMaximize" />
            </mousebind>
          </context>

          <context name="WindowMenu">
            <mousebind button="Left" action="Click">
              <action name="ShowMenu" menu="client-menu" />
            </mousebind>
          </context>

          <context name="Iconify">
            <mousebind button="left" action="Click">
              <action name="Iconify" />
            </mousebind>
          </context>

          <context name="Close">
            <mousebind button="Left" action="Click">
              <action name="Close" />
            </mousebind>
          </context>

          <context name="Client">
            <mousebind button="Left" action="Press">
              <action name="Focus" />
              <action name="Raise" />
            </mousebind>
            <mousebind button="Middle" action="Press">
              <action name="Focus" />
              <action name="Raise" />
            </mousebind>
            <mousebind button="Right" action="Press">
              <action name="Focus" />
              <action name="Raise" />
            </mousebind>
          </context>

          <context name="Root">
            <mousebind button="Left" action="Press">
              <action name="ShowMenu" menu="root-menu" />
            </mousebind>
            <mousebind button="Right" action="Press">
              <action name="ShowMenu" menu="root-menu" />
            </mousebind>
            <mousebind button="Middle" action="Press">
              <action name="ShowMenu" menu="root-menu" />
            </mousebind>
            <mousebind direction="Up" action="Scroll">
              <action name="GoToDesktop" to="left" />
            </mousebind>
            <mousebind direction="Down" action="Scroll">
              <action name="GoToDesktop" to="right" />
            </mousebind>
          </context>

        </mouse>

        <!--
          The *category* element can be set to touch, non-touch, default or the name
          of a device. You can obtain device names by running *libinput list-devices*
          as root or member of the input group.

          Tap is set to *yes* be default. All others are left blank in order to use
          device defaults.

          All values are [yes|no] except for:
            - pointerSpeed [-1.0 to 1.0]
            - accelProfile [flat|adaptive]
            - tapButtonMap [lrm|lmr]
        -->
        <libinput>
          <device category="">
            <naturalScroll></naturalScroll>
            <leftHanded></leftHanded>
            <pointerSpeed></pointerSpeed>
            <accelProfile></accelProfile>
            <tap>yes</tap>
            <tapButtonMap></tapButtonMap>
            <middleEmulation></middleEmulation>
            <disableWhileTyping></disableWhileTyping>
          </device>
        </libinput>

        <!--
          Window Rules
            - Criteria can consist of 'identifier' or 'title' or both (in which case
              AND logic is used).
            - 'identifier' relates to app_id for native Wayland windows and WM_CLASS
              for XWayland clients.
            - Matching against patterns with '*' (wildcard) and '?' (joker) is
              supported. Pattern matching is case-insensitive.

        <windowRules>
          <windowRule identifier="*"><action name="Maximize"/></windowRule>
          <windowRule identifier="foo" serverDecoration="yes"/>
          <windowRule title="bar" serverDecoration="yes"/>
          <windowRule identifier="baz" title="quax" serverDecoration="yes"/>
        </windowRules>
        -->

      </labwc_config>
    '';
  };
}
