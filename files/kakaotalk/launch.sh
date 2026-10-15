export WINEPREFIX="${XDG_DATA_HOME:-$HOME/.local/share}/kakaotalk/wine"
export WINEARCH=win64
export WINEDEBUG="${WINEDEBUG:--all}"
export WINEDLLOVERRIDES="winemenubuilder.exe=d${WINEDLLOVERRIDES:+;$WINEDLLOVERRIDES}"
unset LC_ALL LC_CTYPE
export LANG=ko_KR.UTF-8

executable="$WINEPREFIX/drive_c/Program Files/Kakao/KakaoTalk/KakaoTalk.exe"

if [[ "${1:-}" == --install || ! -f "$executable" ]]; then
  mkdir -p "$(dirname "$WINEPREFIX")"
  exec 9>"$WINEPREFIX.lock"
  flock 9

  if [[ "${1:-}" == --install || ! -f "$executable" ]]; then
    installer="${2:-}"
    if [[ -z "$installer" ]]; then
      cache="${XDG_CACHE_HOME:-$HOME/.cache}/kakaotalk"
      mkdir -p "$cache"
      installer="$cache/KakaoTalk_Setup.exe"
      curl --fail --location --retry 3 --proto '=https' --proto-redir '=https' \
        --output "$installer.part" \
        https://lk.kakaocdn.net/talkpc/talk/win32/x64/KakaoTalk_Setup.exe
      mv "$installer.part" "$installer"
    fi
    installer="$(realpath -- "$installer")"
    if [[ ! -f "$installer" ]]; then
      echo "KakaoTalk installer not found: $installer" >&2
      exit 1
    fi

    wineboot --init
    mkdir -p "$WINEPREFIX/drive_c/windows/Fonts"
    ln -sf "$KAKAOTALK_FONTS/"*.ttf "$WINEPREFIX/drive_c/windows/Fonts/"
    wine regedit /S "$KAKAOTALK_FONT_REGISTRY"
    # XWayland uses the session's XIM input method, including Kime.
    wine reg add 'HKCU\Software\Wine\Drivers' /v Graphics /d x11 /f
    wine "$installer" /S

    if [[ ! -f "$executable" ]]; then
      echo "KakaoTalk installation did not produce $executable" >&2
      exit 1
    fi
  fi

  exec 9>&-
  if [[ "${1:-}" == --install ]]; then
    echo "KakaoTalk installed. Run kakaotalk to sign in."
    exit 0
  fi
fi

cd "$(dirname "$executable")"
exec wine "$executable" "$@"
