class Matrics {

  Table table;
  Table saveTable;
  Simulation simulation;
  Cell cell;
  Cell[] cellNeighbors;
  int l, w, h;
  int[] x = {};
  int[] y = {};
  int[] z = {};




  Matrics(Table tableInput, int cellSize, int sWidth, int sHeight) {
    table = tableInput;
    l = cellSize;
    w = sWidth;
    h = sHeight;
    simulation = new Simulation(l, w, h);
    cellNeighbors = new Cell[8];
    saveTable = new Table();
    saveTable.addColumn("x");
    saveTable.addColumn("y");
    saveTable.addColumn("state");
  }

  void randomize() {
    int[] a = new int[25];
    int[] b = new int[25];
    int[] c = new int[25];
    for (int n = 0; n < a.length; ++n) {
      a[n] = int(random(-5, 5));
      b[n] = int(random(-5, 5));
      c[n] = int(random(0, 4));
    }
    x = a;
    y = b;
    z = c;
  }

  Table screenshot() {
    for (int r = 0; r < x.length; ++r) {
      TableRow newRow = saveTable.addRow();
      newRow.setInt("x", x[r]);
      newRow.setInt("y", y[r]);
      if (z[r]==1) newRow.setString("state", "blue");
      else if (z[r]==2) newRow.setString("state", "green");
      else if (z[r]==3) newRow.setString("state", "Red");
    }
    return saveTable;
  }

  void readTable() {
    for (TableRow row : table.rows()) {
      x =  append(x, row.getInt("x"));
      y = append(y, row.getInt("y"));
      if (row.getString("state").equals("blue")) z = append(z, 1);
      else if (row.getString("state").equals("green")) z = append(z, 2);
      else if (row.getString("state").equals("Red")) z = append(z, 3);
      else z = append(z, 0);
    }
  }

  void drawGen() {
    int[][] nextState = new int[int(w/l)][int(h/l)];
    if (x.length > 0) {
      if (dist(min(x), 0, max(x), 0) >= int(w/l) || dist(0, min(y), 0, max(y)) >= int(h/l))print("Error: Input larger than the grid.");
      else {
        for (int n = 0; n < int(w/l); ++n) {
          for (int m = 0; m < int(h/l); ++m) {
            boolean found = false;
            cell = new Cell(ia(n, m));
            for (int c = 0; !found && c < x.length; ++c) {
              if (n == x[c]+int((w/l)/2) && m == y[c]+int((w/l)/2)) {
                if (n >= int(w/l)) nextState[n][m] = cell.getNextState(neighbors(ia(n-1, m), ia(n-1, m-1), ia(n, m-1), ia(n-int(w/l), m-1), ia(n-int(w/l), m), ia(n-int(w/l), m+1), ia(n, m+1), ia(n-1, m+1)));
                else if (n < 0) nextState[n][m] = cell.getNextState(neighbors(ia(n+int(w/l), m), ia(n+int(w/l), m-1), ia(n, m-1), ia(n+1, m-1), ia(n+1, m), ia(n+1, m+1), ia(n, m+1), ia(n+int(w/l), m+1)));
                else if (m >= int(h/l)) nextState[n][m] = cell.getNextState(neighbors(ia(n-1, m), ia(n-1, m-1), ia(n, m-1), ia(n+1, m-1), ia(n+1, m), ia(n+1, m-int(h/l)), ia(n, m-int(h/l)), ia(n-1, m-int(h/l))));
                else if (m < 0) nextState[n][m] = cell.getNextState(neighbors(ia(n-1, m), ia(n-1, m+int(h/l)), ia(n, m+int(h/l)), ia(n+1, m+int(h/l)), ia(n+1, m), ia(n+1, m+1), ia(n, m+1), ia(n-1, m+1)));
                else if (n >= int(w/l) && m < 0) nextState[n][m] = cell.getNextState(neighbors(ia(n-1, m), ia(n-1, m+int(h/l)), ia(n, m+int(h/l)), ia(n-int(w/l), m+int(h/l)), ia(n-int(w/l), m), ia(n-int(w/l), m+1), ia(n, m+1), ia(n-1, m+1)));
                else if (n >= int(w/l) && m >= int(h/l)) nextState[n][m] = cell.getNextState(neighbors(ia(n-1, m), ia(n-1, m-1), ia(n, m-1), ia(n-int(w/l), m-1), ia(n-int(w/l), m), ia(n-int(w/l), m-int(h/l)), ia(n, m-int(h/l)), ia(n-1, m-int(h/l))));
                else if (n < 0 && m >= int(h/l)) nextState[n][m] = cell.getNextState(neighbors(ia(n+int(w/l), m), ia(n+int(w/l), m-1), ia(n, m-1), ia(n+1, m-1), ia(n+1, m), ia(n+1, m-int(h/l)), ia(n, m-int(h/l)), ia(n+int(w/l), m-int(h/l))));
                else if (n < 0 && m < 0) nextState[n][m] = cell.getNextState(neighbors(ia(n+int(w/l), m), ia(n+int(w/l), m+int(h/l)), ia(n, m+int(h/l)), ia(n+1, m+int(h/l)), ia(n+1, m), ia(n+1, m+1), ia(n, m+1), ia(n+int(w/2), m+1)));
                else nextState[n][m] = cell.getNextState(neighbors(ia(n-1, m), ia(n-1, m-1), ia(n, m-1), ia(n+1, m-1), ia(n+1, m), ia(n+1, m+1), ia(n, m+1), ia(n-1, m+1)));
                found = true;
              }
            }
            if (!found) {
              if (n >= int(w/l)) nextState[n][m] = cell.getNextState(neighbors(ia(n-1, m), ia(n-1, m-1), ia(n, m-1), ia(n-int(w/l), m-1), ia(n-int(w/l), m), ia(n-int(w/l), m+1), ia(n, m+1), ia(n-1, m+1)));
              else if (n < 0) nextState[n][m] = cell.getNextState(neighbors(ia(n+int(w/l), m), ia(n+int(w/l), m-1), ia(n, m-1), ia(n+1, m-1), ia(n+1, m), ia(n+1, m+1), ia(n, m+1), ia(n+int(w/l), m+1)));
              else if (m >= int(h/l)) nextState[n][m] = cell.getNextState(neighbors(ia(n-1, m), ia(n-1, m-1), ia(n, m-1), ia(n+1, m-1), ia(n+1, m), ia(n+1, m-int(h/l)), ia(n, m-int(h/l)), ia(n-1, m-int(h/l))));
              else if (m < 0) nextState[n][m] = cell.getNextState(neighbors(ia(n-1, m), ia(n-1, m+int(h/l)), ia(n, m+int(h/l)), ia(n+1, m+int(h/l)), ia(n+1, m), ia(n+1, m+1), ia(n, m+1), ia(n-1, m+1)));
              else if (n >= int(w/l) && m < 0) nextState[n][m] = cell.getNextState(neighbors(ia(n-1, m), ia(n-1, m+int(h/l)), ia(n, m+int(h/l)), ia(n-int(w/l), m+int(h/l)), ia(n-int(w/l), m), ia(n-int(w/l), m+1), ia(n, m+1), ia(n-1, m+1)));
              else if (n >= int(w/l) && m >= int(h/l)) nextState[n][m] = cell.getNextState(neighbors(ia(n-1, m), ia(n-1, m-1), ia(n, m-1), ia(n-int(w/l), m-1), ia(n-int(w/l), m), ia(n-int(w/l), m-int(h/l)), ia(n, m-int(h/l)), ia(n-1, m-int(h/l))));
              else if (n < 0 && m >= int(h/l)) nextState[n][m] = cell.getNextState(neighbors(ia(n+int(w/l), m), ia(n+int(w/l), m-1), ia(n, m-1), ia(n+1, m-1), ia(n+1, m), ia(n+1, m-int(h/l)), ia(n, m-int(h/l)), ia(n+int(w/l), m-int(h/l))));
              else if (n < 0 && m < 0) nextState[n][m] = cell.getNextState(neighbors(ia(n+int(w/l), m), ia(n+int(w/l), m+int(h/l)), ia(n, m+int(h/l)), ia(n+1, m+int(h/l)), ia(n+1, m), ia(n+1, m+1), ia(n, m+1), ia(n+int(w/2), m+1)));
              else nextState[n][m] = cell.getNextState(neighbors(ia(n-1, m), ia(n-1, m-1), ia(n, m-1), ia(n+1, m-1), ia(n+1, m), ia(n+1, m+1), ia(n, m+1), ia(n-1, m+1)));
            }
          }
        }
        for (int n = 0; n < int(w/l); ++n) {
          for (int m = 0; m < int(h/l); ++m) {
            boolean found = false;
            for (int c = 0; !found && c < x.length; ++c) {
              if (n == x[c]+int((w/l)/2) && m == y[c]+int((w/l)/2)) {
                if (nextState[n][m] == 0) {
                  x[c] = x[x.length-1];
                  y[c] = y[y.length-1];
                  z[c] = z[z.length-1];
                  x = shorten(x);
                  y = shorten(y);
                  z = shorten(z);
                } else z[c] = nextState[n][m];
                found = true;
              }
            }
            if (!found) {
              if (nextState[n][m] != 0) {
                x = append(x, n-int((w/l)/2));
                y = append(y, m-int((h/l)/2));
                z = append(z, nextState[n][m]);
              }
            }
          }
        }
      }
    }
  }

  Cell[] neighbors(int n1, int n2, int n3, int n4, int n5, int n6, int n7, int n8) {
    cellNeighbors[0] = new Cell(n1);
    cellNeighbors[1] = new Cell(n2);
    cellNeighbors[2] = new Cell(n3);
    cellNeighbors[3] = new Cell(n4);
    cellNeighbors[4] = new Cell(n5);
    cellNeighbors[5] = new Cell(n6);
    cellNeighbors[6] = new Cell(n7);
    cellNeighbors[7] = new Cell(n8);
    return cellNeighbors;
  }

  int ia(int px, int py) {
    for (int cn = 0; cn < x.length; ++cn) {
      if (px == x[cn]+int((w/l)/2) && py == y[cn]+int((w/l)/2)) {
        return int(z[cn]);
      }
    }
    return 0;
  }

  void drawTable() {
    for (int i=0; i < x.length; ++i) {
      simulation.drawGrid(x[i]+int((w/l)/2), y[i]+int((h/l)/2), z[i]);
    }
  }
}
