;;; ホワイトボードの背景を白に統一
;;; https://github.com/halueda/white_board_sharpener
;;; 
;;; Author: Haruyasu Ueda <MAE03130@nifty.com>
;;; Version 0.01

(define (white-board-sharp img layer)
  (let ((using_layer nil))
;    (gimp-image-undo-disable img)
    (gimp-image-undo-group-start img)

    ;;・レイヤー＞レイヤーをコピー
    (set! using_layer (car (gimp-layer-copy layer 1)))
    (gimp-image-add-layer img using_layer -1)

    ;;・フィルタ＞ぼかし＞ガウシアンぼかし200x200
    (plug-in-gauss-iir2 1 img using_layer 200 200)

    ;;・レイヤーモードを除算
    (gimp-layer-set-mode using_layer DIVIDE-MODE)
    ;;・レイヤー＞画像の統合（レイヤー）
    (gimp-image-merge-down img using_layer 0)
    
    (set! using_layer (car (gimp-image-get-active-layer img)))
    ;;
    ;;・ツール＞強調＞アンシャープマスク 半径4 量1.4 閾値 8
    (plug-in-unsharp-mask 1 img using_layer 4 1.4 8)

    ;;・色＞明るさ-コントラストで、背景が荒れない程度にコントラストを極大・背景を白くつぶす
    ;; これは必要なら手動で。なくても十分OK

;    (gimp-image-undo-enable img)
    (gimp-image-undo-group-end img)
    (gimp-displays-flush)
    )
)

(script-fu-register "white-board-sharp"
		    "<Image>/Script-Fu/White Board Sharpner..."
  "Make background white and extra contrast for drawings."
  "Haruyasu Ueda <hal_ueda@jp.fujitsu.com>"
  "Haruyasu Ueda"
  "2014"
  "RGB*"
;  ""
  SF-IMAGE      "Image"             0
  SF-DRAWABLE   "Drawable to apply" 0
  ;SF-ADJUSTMENT _"Mask size"        '(5 1 100 1 1 0 1)
  ;SF-ADJUSTMENT _"Mask opacity"     '(50 0 100 1 1 0 1)
  ;  SF-ADJUSTMENT COMMENT     '(default min max step_s step_l float_accur slider0_or_text1)
)
