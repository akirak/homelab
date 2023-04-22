let
  inherit (builtins) toJSON isFunction;

  defaultModulesRight = [
    "idle_inhibitor"
    "pulseaudio"
    "network"
    "cpu"
    "memory"
    "temperature"
    "backlight"
    "keyboard-state"
    "custom/nixos"
    "clock"
    "tray"
  ];
in
{
  writeText,
  modulesCenter ? ["wlr/workspaces"],
  modulesLeft ? [],
  modulesRight ? defaultModulesRight,
}:
# Based on https://github.com/Alexays/Waybar/blob/master/resources/config
writeText "config" ''
  {
    "height": 30,
    "spacing": 4,
    "modules-left": ${toJSON modulesLeft},
    "modules-center": ${toJSON modulesCenter},
    "modules-right": ${toJSON (
      if isFunction modulesRight
      then modulesRight defaultModulesRight
      else modulesRight
    )},
    "keyboard-state": {
      "numlock": true,
      "capslock": true,
      "format": "{name} {icon}",
      "format-icons": {
      "locked": "",
      "unlocked": ""
      }
    },
    "sway/mode": {
      "format": "<span style=\"italic\">{}</span>"
    },
    "sway/scratchpad": {
      "format": "{icon} {count}",
      "show-empty": false,
      "format-icons": ["", ""],
      "tooltip": true,
      "tooltip-format": "{app}: {title}"
    },
    "wlr/workspaces": {
      "format": "{name}",
      "format-icons": {
        "1": "",
        "2": "",
        "3": "",
        "4": "",
        "5": "",
        "urgent": "",
        "active": "",
        "default": ""
      },
      "on-click": "activate"
    },
    "hyprland/window": {
      "format": "{}",
      "separate-outputs": true
    },
    "hyprland/submap": {
      "format": "✌️ {}",
      "max-length": 8,
      "tooltip": false
    },
    "idle_inhibitor": {
      "format": "{icon}",
      "format-icons": {
        "activated": "",
        "deactivated": ""
      }
    },
    "tray": {
      "spacing": 10
    },
    "clock": {
      "format-alt": "{:%Y-%m-%d}",
      "tooltip-format": "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>"
    },
    "cpu": {
      "format": "{usage}% ",
      "tooltip": false
    },
    "memory": {
      "format": "{}% "
    },
    "temperature": {
      "critical-threshold": 80,
      "format": "{temperatureC}°C {icon}",
      "format-icons": ["", "", ""]
    },
    "backlight": {
      "format": "{percent}% {icon}",
      "format-icons": ["", "", "", "", "", "", "", "", ""]
    },
    "battery": {
      "states": {
        "warning": 30,
        "critical": 15
      },
      "format": "{capacity}% {icon}",
      "format-charging": "{capacity}% ",
      "format-plugged": "{capacity}% ",
      "format-alt": "{time} {icon}",
      "format-icons": ["", "", "", "", ""]
    },
    "battery#bat2": {
      "bat": "BAT2"
    },
    "network": {
      "format-wifi": "{essid} ({signalStrength}%) ",
      "format-ethernet": "{ipaddr}/{cidr} ",
      "tooltip-format": "{ifname} via {gwaddr} ",
      "format-linked": "{ifname} (No IP) ",
      "format-disconnected": "Disconnected ⚠",
      "format-alt": "{ifname}: {ipaddr}/{cidr}"
    },
    "pulseaudio": {
      "format": "{volume}% {icon} {format_source}",
      "format-bluetooth": "{volume}% {icon} {format_source}",
      "format-bluetooth-muted": " {icon} {format_source}",
      "format-muted": " {format_source}",
      "format-source": "{volume}% ",
      "format-source-muted": "",
      "format-icons": {
        "headphone": "",
        "hands-free": "",
        "headset": "",
        "phone": "",
        "portable": "",
        "car": "",
        "default": ["", "", ""]
      },
      "on-click": "pavucontrol"
    },
    "custom/nixos": {
      "interval": 60,
      "exec": "nixos-version --configuration-revision"
    }
  }
''
