;
; Draw and move the gun
;
; Gun drawn using "half character" movement through PETSCII chars so
; movement is either by switching internal chars or by moving position 
; (and switching chars)
;
; This is pretty simple here, look at the "enemy" code for a more general
; sub-char movement description
;

%import gun_bullets

gun {
  ubyte x
  ubyte y

  ubyte post_hit = 0

  byte direction = 0
  ubyte gun_color = 14 ; Light blue

  const ubyte GUN_MAX_LEFT = base.LBORDER + 1
  const ubyte GUN_MAX_RIGHT = base.RBORDER - 3

  ubyte[] gun_l = [ 254, 251, 123 ]
  ubyte[] gun_r = [ 108, 236, 252 ]

  ubyte leftmost = true;

  ubyte i ; shared loop variable

  sub set_data() {
    post_hit = 0 ; Make sure we have hit animation off at startup

    ; Default start position of gun
    x = ( base.RBORDER - base.LBORDER ) / 2
    y = base.DBORDER - 1
    draw()
  }

  sub clear() {
    for i in 0 to 2 {
      txt.setcc( x + i, y, main.CLR, 0 )
    }
  }

  sub draw() {
    if leftmost {
      for i in 0 to 2 {
        txt.setcc( x + i, y, gun_l[i], gun_color )
      }
    } else {
      for i in 0 to 2 {
        txt.setcc( x + i, y, gun_r[i], gun_color )
      }    
    }
  }

  sub set_left() {
    direction = -1
  }

  sub set_right() {
    direction = 1
  }

  sub move() {
    if post_hit { 
      post_hit--

      if post_hit > 25
        return

      if post_hit % 2
        gun_color = 0
      else 
        gun_color = 14
    }

    if direction  < 0 {
      move_left()
      return
    }

    if direction > 0 {
      move_right()
      return
    }

    draw() ; Needed after "kill".
  }

  sub move_left() {
    if ( x <= GUN_MAX_LEFT and leftmost )
      return
      
    if leftmost {
      clear()
      x--
      leftmost = false;
      draw()
    } else {
      leftmost=true
      draw()
    }
  }

  sub move_right() {
    if ( x >= GUN_MAX_RIGHT and not leftmost )
      return

    if leftmost {
      leftmost = false;
      draw()
    } else {
      clear()
      x++
      leftmost=true
      draw()
    }
  }

  sub fire() {
    if main.stage_start_delay ; No bullets in stage end/start
      return
    sound.fire()
    gun_bullets.trigger(x+1, y-1, leftmost)
  }

  sub check_collision(uword BombRef) -> ubyte {
    ; Check that we are not in "quaranteen" from last hit
    if post_hit 
      return 0

    if BombRef[bombs.BMB_X] < gun.x
      return 0
    if BombRef[bombs.BMB_X] > gun.x + 2
      return 0

    ; Check if bomb passes on the left or right side of gun
    ubyte dx = BombRef[bombs.BMB_X] - gun.x
    when dx {
      0 -> { ; bomb to the left and gun in "righmost" pos?
             if BombRef[bombs.BMB_LEFTMOST]
               if ~leftmost
                 return 0
            }
      2 -> { ; bomb to the right and gun in "leftmost" pos?
             if leftmost
               if ~BombRef[bombs.BMB_LEFTMOST]
                 return 0
           }
    }

    ; We have a hit, explode and deduct a life
    sound.large_explosion()
    main.player_lives--
    main.printLives()
    direction=0 
    post_hit = 40
    explosion.trigger(gun.x, gun.y-1, main.LEFTMOST);
    explosion.trigger(gun.x+1, gun.y-1, main.LEFTMOST);

    return 1
  }

}
