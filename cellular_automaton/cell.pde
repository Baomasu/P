/*
 * This class represents a cell in the grid of a game of life inspired from Conway's Game of Life.
 * Resources found on www.conwaylife.com/wiki/OCA:Brew
 */
class Cell {
  int state; // 0: dead, 1: blue, 2: green, 3: red

  Cell(int stateIn) {
    state = stateIn; // initialize cell with input state
  }

  int getNextState(Cell[] neighbors) {
    /*
            * Cette méthode implément les règles du jeux de la vie de Conway.
     * Des cellules naissent, vivent, ou meurent selon le nombre de voisins vivants qu'elles ont, en incluant les diagonaless
     * - États des cellules : Il y a quatre états possibles pour les cellules : morte, bleue, verte, ou rouge.
     * - Chaque cellule naît, survit, ou meurt selon ses voisins de même couleur.
     *   - naissance : une cellule morte avec exactement trois voisins vivants devient vivante.
     *   - survie : une cellule vivante avec deux ou trois voisins vivants reste vivante.
     *   - mort : dans tous les autres cas, la cellule meurt ou reste morte.
     * - Une cellule rouge devient verte au lieu de mourir ; une cellule verte devient bleue au lieu de mourir.
     * - Cependant, une cellule rouge mourante avec trois voisins bleus devient une cellule bleue, plutôt que verte.
     */

    int blueCount = 0;
    int greenCount = 0;
    int redCount = 0;

    int next_state = state;

    for (Cell neighbor : neighbors) {
      if (neighbor.state == 1) {
        blueCount++;
      } else if (neighbor.state == 2) {
        greenCount++;
      } else if (neighbor.state == 3) {
        redCount++;
      }
    }

    // rules in order of priority
    if (state == 3) {
      // Rule for live red cells
      if (redCount < 2 || redCount > 3) {
        // decay condition for red cells
        if (blueCount == 3) {
          next_state = 1; // rapid decay
        } else {
          next_state = 2; // decay
        }
      } else {
        next_state = 3; // red survives
      }
    } else if (redCount == 3) {
      next_state = 3; // red birth
    } else if (state == 2) {
      // Rule for live green cells
      if (greenCount < 2 || greenCount > 3) {
        next_state = 1; // decay
      } else {
        next_state = 2; // survives
      }
    } else if (greenCount == 3) {
      next_state = 2; // green birth
    } else if (state == 1) {
      // Rule for live blue cells
      if (blueCount < 2 || blueCount > 3) {
        next_state = 0; // dead
      } else {
        next_state = 1; // survives
      }
    } else if (blueCount == 3) {
      next_state = 1; // blue birth
    } else {
      next_state = 0; // stay dead
    }
    return next_state;
  }
}
