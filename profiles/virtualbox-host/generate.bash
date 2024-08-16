#!/usr/bin/env bash

vm_dir="${VIRTUALBOX_VM_DIR:-$HOME/VirtualBox VMs}"
data_home="${XDG_DATA_HOME:-$HOME/.local/share}"
data_dir="${data_home}/virtualbox-items"
applications_dir="${data_home}/applications"

boxes=()

function prepareDirectory() {
  mkdir -p "${data_dir}"
  find "${data_dir}" -name '*.desktop' -delete
}

function generateDesktopItem() {
  local name="$1"
  cat <<-CONTENT
    [Desktop Entry]
    Type=Application
    Name=$name on VirtualBox
    TryExec=VirtualBoxVM
    Exec=VirtualBoxVM --startvm "$name"
    Icon=virtualbox-vbox
CONTENT
}

function createItems() {
  for box in "${boxes[@]}"; do
    outfile="${data_dir}/$box.desktop"
    generateDesktopItem "$box" > "$outfile"
    ln -sf -t "${applications_dir}" "$outfile"
    echo "$box"
  done
}

function cleanupObsoleteItems() {
  while read -r f; do
    dest=$(readlink "$f")
    if [[ $dest = ${data_dir}/* ]] && ! [[ -e "$dest" ]]; then
      rm -v "$f"
    fi
  done < <(find "${applications_dir}" -maxdepth 1 -name '*.desktop')
}

if ! [[ -d "${vm_dir}" ]]; then
  echo >&2 "Directory ${vm_dir} does not exist"
  exit 0
fi

while read -r filename; do
  boxes+=("$filename")
done < <(find "${vm_dir}" -maxdepth 3 -name '*.vbox' -exec basename -s .vbox {} \;)

if [[ ${#boxes[@]} -eq 0 ]]; then
  echo >&2 "No vbox file exists in ${vm_dir}"
  exit 0
fi

prepareDirectory
createItems
cleanupObsoleteItems

xdg-desktop-menu forceupdate
