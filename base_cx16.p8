%import sound_cx16

base {

  ; Define playfield limits
  const ubyte LBORDER = 0
  const ubyte RBORDER = 30;
  const ubyte UBORDER = 2
  const ubyte DBORDER = UBORDER + 24;

  sub platform_setup() {
    ; Set 40 column mode 
    void cx16.screen_set_mode(0)
    ; Init sound
    sound.init()
  }

  sub clear_screen() {
    ubyte x
    ubyte y
    for x in 0 to 39 
      for y in 0 to 29 
        txt.setcc( x, y, main.CLR, 0 )
  }

  ; This simple additional decor is only for the X16
  sub draw_extra_border() {
    ubyte i
    for i in 0 to 39 {
      txt.setcc( i, UBORDER-1, $62, 12 )
      txt.setcc( i, DBORDER+1, $E2, 12 )
    }
  }

}