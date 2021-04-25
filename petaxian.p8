%target cx16
%import syslib
%import textio

%import splash
%import decor
%import gun
%import enemy
%import bombs

main {
  const ubyte CLR = $20

  ; Define playfield limits
  const ubyte LBORDER = 0
  const ubyte RBORDER = 30;
  const ubyte UBORDER = 0
  const ubyte DBORDER = 24;

  uword score = 0
  ubyte cur_wave = 0

  ; Variable enemy speed
  ubyte enemy_speed = 3
  ubyte enemy_sub_counter

  ; Fixed player speed? Power ups? Split gun/bullet speed?
  ubyte player_lives = 3
  ubyte player_speed = 2
  ubyte player_sub_counter

  sub start() {
  void cx16.screen_set_mode(0)

  splash.draw()
  splash.write( 3, LBORDER + 10, UBORDER + 20, "press space to start" )

  wait_space();

  splash.clear()
  decor.draw()

  printScore()
  printLives()

  gun.x = ( RBORDER - LBORDER ) / 2
  gun.y = DBORDER - 1
  gun.draw()
    
  enemy.setup_wave(cur_wave)
;  enemy.draw()

gameloop:
    ubyte time_lo = lsb(c64.RDTIM16())

    ; May needed to find a better timer
    if time_lo >= 1 {
      c64.SETTIM(0,0,0)

      ; Player movements
      player_sub_counter++
      if player_sub_counter == player_speed {
        gun_bullets.move()
        gun.move()
	player_sub_counter = 0
      }

      ; Enemy movement
      enemy_sub_counter++
      if enemy_sub_counter == enemy_speed {
        ; move enemies
        enemy.move_all()
	enemy_sub_counter = 0
        bombs.move()      
        enemy.spawn_bomb()
      }

      if (enemy.enemies_left == 0) {
        cur_wave++
        if cur_wave > 1 ; only two "waves" right now
          cur_wave = 0
        enemy.setup_wave(cur_wave)
	printWave()
      }
    }

    ubyte key = c64.GETIN()
    if key == 0 goto gameloop

    keypress(key)

    goto gameloop
  } 

  sub plot(ubyte x, ubyte y, ubyte ch) {
     txt.setcc(x, y, ch, 1 )
  }

  sub printScore() {
    uword tmp = score

    ubyte var = tmp % 10 as ubyte
    txt.setcc(RBORDER + 8, UBORDER + 2, var+176, 1)
    tmp /= 10
    var = tmp % 10 as ubyte
    txt.setcc(RBORDER + 7, UBORDER + 2, var+176, 1)
    tmp /= 10
    var = tmp % 10 as ubyte
    txt.setcc(RBORDER + 6, UBORDER + 2, var+176, 1)
    tmp /= 10
    var = tmp % 10 as ubyte
    txt.setcc(RBORDER + 5, UBORDER + 2, var+176, 1)
    var = tmp / 10 as ubyte
    txt.setcc(RBORDER + 4, UBORDER + 2, var+176, 1)
  }

  sub printLives() {
    txt.setcc(RBORDER + 8, UBORDER + 4, player_lives + 176, 1 )
  }

  sub printWave() {
    txt.setcc(RBORDER + 7, UBORDER + 6, cur_wave / 10 + 176, 1)
    txt.setcc(RBORDER + 8, UBORDER + 6, cur_wave % 10 + 176, 1)
  }


  sub wait_space() {
    ubyte key = 0
    while key != 32 {
       key = c64.GETIN()
    }
    return
  }

  sub keypress(ubyte key) {
    when key {
	  157, ',' -> gun.set_left()
	   29, '/' -> gun.set_right()
	   32      -> gun.fire()
    }
  }

}