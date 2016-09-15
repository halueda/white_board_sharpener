;;; ホワイトボードの背景を白に統一
;;; https://github.com/halueda/white_board_sharpener
;;; 
;;; Author: Haruyasu Ueda <MAE03130@nifty.com>
;;; Version 0.01

(define (white-board-sharp img layer)
  (let ((using_layer nil))
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
    
    ;; フィルタ＞変形＞レンズ補正 
;;    (plug-in-lens-distortion run-mode/INT32
;;			     image/IMAGE
;;			     drawable
;;			     offset-x/FLOAT
;;			     offset-y/FLOAT
;;			     main-adjust/FLOAT
;;			     edge-adjust/FLOAT
;;			     resacale/FLOAT
    ;;			     brighten/FLOAT)
    (plug-in-lens-distortion 1             ;;  run-mode/INT32 non-interactive =1
			     img           ;;  image
			     using_layer   ;;  drawable                      
			     0.0	   ;;  offset-x/FLOAT                
			     0.0	   ;;  offset-y/FLOAT                
			     -5.0	   ;;  main-adjust/FLOAT             
			     0.0	   ;;  edge-adjust/FLOAT             
			     0.0	   ;;  resacale/FLOAT 
			     0.0)	   ;;  brighten/FLOAT)
    (gimp-image-undo-group-end img)

    ;;・色＞明るさ-コントラストで、背景が荒れない程度にコントラストを極大・背景を白くつぶす
    ;; これは必要なら手動で。なくても十分OK。ここだけundoで戻せるようにする。
    (gimp-brightness-contrast using_layer
			      -120 ;; inBrightness/INT
			      127 ;; inContrast/INT
			      )

    (gimp-displays-flush)
    )
)
