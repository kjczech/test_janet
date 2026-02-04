
```janet
(def grammar
  ~{:ws (set " \t\r\f\n\0\v")
    :readermac (set "';~,|")
    :symchars (+ (range "09" "AZ" "az" "\x80\xFF") (set "!$%&*+-./:<?=>@^_"))
    :token (some :symchars)
    :hex (range "09" "af" "AF")
    :escape (* "\\" (+ (set `"'0?\abefnrtvz`)
                       (* "x" :hex :hex)
                       (* "u" [4 :hex])
                       (* "U" [6 :hex])
                       (error (constant "bad escape"))))
    :comment (* "#" (any (if-not (+ "\n" -1) 1)))
    :symbol :token
    :keyword (* ":" (any :symchars))
    :constant (* (+ "true" "false" "nil") (not :symchars))
    :bytes (* "\"" (any (+ :escape (if-not "\"" 1))) "\"")
    :string :bytes
    :buffer (* "@" :bytes)
    :long-bytes {:delim (some "`")
                 :open (capture :delim :n)
                 :close (cmt (* (not (> -1 "`")) (-> :n) '(backmatch :n)) ,=)
                 :main (drop (* :open (any (if-not :close 1)) :close))}
    :long-string :long-bytes
    :long-buffer (* "@" :long-bytes)
    :number (cmt (<- :token) ,scan-number)
    :raw-value (+ :comment :constant :number :keyword
                  :string :buffer :long-string :long-buffer
                  :parray :barray :ptuple :btuple :struct :dict :symbol)
    :value (* (any (+ :ws :readermac)) :raw-value (any :ws))
    :root (any :value)
    :root2 (any (* :value :value))
    :ptuple (* "(" :root (+ ")" (error "")))
    :btuple (* "[" :root (+ "]" (error "")))
    :struct (* "{" :root2 (+ "}" (error "")))
    :parray (* "@" :ptuple)
    :barray (* "@" :btuple)
    :dict (* "@" :struct)
    :main :root})
```


```janet

(defmacro max3
 "Get the max of two values."
 [x y]
 (def $x (gensym))
 (def $y (gensym))
 ~(let [,$x ,x
        ,$y ,y]
    (if (> ,$x ,$y) ,$x ,$y)))

```




```janet
# --- Imports / context ---
(use jw32/_winuser)
(use jw32/_util)
(use jwno/util)

(def {:window-manager window-man
      :key-manager    key-man
      :command-manager command-man} jwno/context)

# --- Helper: place the focused window in the top-left quadrant of the current monitor ---
(defn place-focused-window-upper-left []
  (def cur-frame (:get-current-frame (in window-man :root)))
  (def top-frame (:get-top-frame cur-frame))

  (def mon-rect (in top-frame :rect))
  (def [mon-w mon-h] (rect-size mon-rect))

  (def x (in mon-rect :left))
  (def y (in mon-rect :top))
  (def w (math/floor (/ mon-w 2)))
  (def h (math/floor (/ mon-h 2)))

  (def hwnd
    (or (try (:get-focused-hwnd window-man)
             (catch _ nil))
        (GetForegroundWindow)))

  (when hwnd
    (SetWindowPos hwnd nil x y w h
      (bor SWP_NOZORDER SWP_NOACTIVATE SWP_SHOWWINDOW))))

# --- Command: open Chrome and place it upper-left ---
(defn cmd-chrome-upper-left []
  (:call-command command-man :exec
    "C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe")

  (ev/sleep 0.35)
  (place-focused-window-upper-left))

(:add-command command-man :chrome-upper-left cmd-chrome-upper-left)

# --- Key binding ---
(def keymap (:new-keymap key-man))

;; 🔑 Hotkey: Win + Ctrl + F2
(:define-key keymap "Win + Ctrl + F2"
             :chrome-upper-left
             "Open Chrome in the upper-left quadrant")

(:set-keymap key-man keymap)

```
