;;; watch-macro.el ---
;;
;; Filename: watch-macro.el
;; Description:
;; Author: Andreas Karlsson
;; Maintainer:
;; Created: ons sep 27 16:28:17 2017 (+0200)
;; Version:
;; Package-Requires: ()
;; Last-Updated:
;;           By:
;;     Update #: 93
;; URL:
;; Doc URL:
;; Keywords:
;; Compatibility:
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;; Commentary:
;;
;;
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;; Change Log:
;;
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; This program is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or (at
;; your option) any later version.
;;
;; This program is distributed in the hope that it will be useful, but
;; WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
;; General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs.  If not, see <http://www.gnu.org/licenses/>.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; DONE:
;; + Naming? watch-macro this is better, watch-buffer etc watch-shell-command
;; + Turn function into macro
;; + Macro input: name + command (use name for function name [e.g. watch-name] and output buffer).
;; + Function input: update interval close time
;; + Allow to hide buffer
;;; TODO:
;; + Create an interactive function that can extend and call the macro from the mod-line
;; + Add similar stuff to buffer as watch e.g. update time, command & clock-time
;; + Support external shells, possibly with additional function input for shell
;;   login (should not be done again and again) - this already seems to work through tramp although it produces an error message
;; + Ability to list switch to buffer and kill scheduled updates
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;; Examples
;;
;; + top: top -n 1 -b
;; + disk:
;; + job:
;; + nmcli: device wifi list
;; + quota:
;; + battery: upower -i /org/freedesktop/UPower/devices/battery_BAT0
;;
;;; Code:

(defmacro watch-shell-macro (name cmd)
  ""
  `(defun ,(intern (format "watch-%s" name)) (&optional update finish) ; function naming from name
     ""
     (interactive)
     (let* ((update-interval (or update 2)) ;default update interval
            (update-stop (or finish "20sec")) ;default time until update stop
            (mytimer (run-at-time nil update-interval #'(lambda ()
                                                          (save-window-excursion
                                                            (with-output-to-temp-buffer ,(concat "*" name "*")
                                                              (shell-command ,cmd
                                                                             ,(concat "*" name "*")
                                                                             "*Messages*")))))))
       (run-at-time update-stop nil #'cancel-timer mytimer)
       (run-at-time update-stop nil #'kill-buffer ,(concat "*" name "*"))
       (pop-to-buffer ,(concat "*" name "*")))))

(watch-shell-macro "wifi2" "nmcli device wifi list")
(watch-wifi2)
(watch-wifi2 2)
(watch-wifi2 2 "20sec")

(watch-shell-macro "top" "top -n 1 -b")
(watch-top)

(watch-shell-macro "battery" "upower -i /org/freedesktop/UPower/devices/battery_BAT0")
(watch-battery 10 "1min")

(global-set-key (kbd "C-x p") (lambda () (interactive) (watch-top)))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; watch-macro.el ends here
