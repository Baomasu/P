let gravityConstant = 9.8;
let rotationalConstant = 0.13;
let forceConstant = 100.0;
let springConstant = 0.2;

let minConnectionLength = 20;
let maxConnectionLength = 40;

let nodes = [];
let connections = [];

let dragging = false;
let dragNode;
let dragLerp = 0.2;

let particles = [];
let particlesPerMass = 5;

let displayGraphics;
let showDebug = false;
let jsonData;

let canvas;

/// button form variables//
let name1;
let name2;
let btn;
let insertForm = document.getElementById("insertForm");
let alertV;
let alertT;

let toggle = false;
let isValid = true;
let match = true;
let devMode = false;
let blankRegex = /^\S*$/;
/////////////////////////


function preload() {
  jsonData = loadJSON('data.json');
}

function setup() {
  canvas = createCanvas(displayWidth, displayHeight, P2D);
  canvas.position(0, 0);
  canvas.style('z-index', '-1');

  displayGraphics = createGraphics(width, height);
  displayGraphics.background(255);
  displayGraphics.translate(displayGraphics.width / 2, displayGraphics.height / 2);
  displayGraphics.rectMode(CENTER);

  // Initialize nodes from JSON
  //jsonData.nodes.forEach(nodeData => {
  //  let pos = createVector(nodeData.x, nodeData.y);
  //  let node = new Node(pos, nodeData.size, nodeData.name); // Pass the name to the Node constructor
  //  nodes.push(node);
  //});


  let node = new Node(createVector(0, 0), random(1, 5));
  nodes.push(node);
  for (let i = 0; i < round(node.mass * particlesPerMass); i++) {
    particles.push(new Particle(node));
  }
  closeNode = node;
}

function addNode(x, y, s) {
  let l = random(minConnectionLength, maxConnectionLength);
  let a = random(TWO_PI);
  let pos = createVector(x + l / 1 * cos(a), y + l / 1 * sin(a));
  let mass = s;
  let node2 = new Node(pos, mass);
  nodes.push(node2);
  for (let i = 0; i < round(node2.mass * particlesPerMass); i++) {
    particles.push(new Particle(node2));
  }
}

function addConnection(s, t, d) {
  let i = s;
  let j = t;
  let l = d;
  connections.push([i, j, l])
}

function update() {
  //if (random() < 0.01) { addNode() }
  //if (random() < 0.001) { addConnection() }
  applyForces()
  nodes.forEach(node => { node.update() });
  particles.forEach(particle => { particle.update() });
  updateDisplay()
}

function updateDisplay() {
  displayGraphics.noStroke();
  displayGraphics.fill(0, 16);
  displayGraphics.rect(0, 0, displayGraphics.width, displayGraphics.height);
  displayGraphics.stroke(255, 128);
  displayGraphics.strokeWeight(1);
  particles.forEach(particle => {
    displayGraphics.point(particle.pos.x, particle.pos.y)
  })
}

function drawDebug() {
  translate(width / 2, height / 2)
  background(255);

  stroke(0)
  connections.forEach(con => {
    node1 = nodes[con[0]]
    node2 = nodes[con[1]]
    line(node1.pos.x, node1.pos.y,
      node2.pos.x, node2.pos.y)
  })

  fill(0)
  nodes.forEach(node => {
    circle(node.pos.x, node.pos.y, node.mass)
  })

  fill(200, 0, 0)
  stroke(200, 0, 0)
  particles.forEach(particle => {
    circle(particle.pos.x, particle.pos.y, 2)
  })
}

function draw() {
  update();
  if (showDebug) {
    drawDebug()
  } else {
    translate(width / 2, height / 2);
    imageMode(CENTER);
    image(displayGraphics, 0, 0)
  }

  if (dragging == true) {
    let dragTarget = createVector(mouseX - width / 2, mouseY - height / 2)
    dragNode.pos.lerp(dragTarget, dragLerp)
    if (dragLerp < 0.95) {
      dragLerp += 0.02;
    }
  }
}

function touchStarted() {
  dragging = true
  dragNode = nodes[0]
  let dragTarget = createVector(mouseX - width / 2, mouseY - height / 2)
  let dragDistance = dragTarget.dist(dragNode.pos)
  nodes.forEach(node => {
    let distance = dragTarget.dist(node.pos)
    if (distance < dragDistance) {
      dragNode = node;
      dragDistance = distance
    }
  })
}

function touchEnded() {
  dragging = false
  dragLerp = 0.2
}

function keyReleased() {
  if ((key == 'd' || key == 'D') && !devMode) {
    showDebug = !showDebug;
    devMode = true;
  }
  else if ((key == 'd' || key == 'D') && devMode) {
    showDebug = !showDebug;
    devMode = false;
  }
  else if (key == 'f' || key == 'F') {
    fullscreen(!fullscreen());
  } //else if (key == ' ') {

  //}
}

addEventListener("keydown", (event) => {
  if ((event.isComposing || event.keyCode === 32) && toggle == false) {
    if (devMode) {
      //Only readible when development mode is on.
      console.log(jsonData.nodes);
      console.log(jsonData.connections);
    }
    loadForm();
    btn = document.getElementById("btn");
    name1 = document.getElementById("input1");
    name2 = document.getElementById("input2");

    alertV = document.getElementById("alertV");
    alertT = document.getElementById("alertT");
    initBtn();
    toggle = true;
    return;
  } else if ((event.isComposing || event.keyCode === 32) && toggle == true) {

    insertForm.innerHTML = ``;
    toggle = false;
  }
});

function applyForces() {
  connections.forEach(conn => {
    let node1 = nodes[conn[0]]
    let node2 = nodes[conn[1]]
    let len = conn[2]
    let dir = node1.pos.copy().sub(node2.pos)
    let displacement = (dir.mag() - len)
    let force = dir.normalize().mult(displacement * springConstant)
    node1.force.sub(force)
    node2.force.add(force)
  })

  for (let i = 0; i < nodes.length; i++) {
    for (let j = i + 1; j < nodes.length; j++) {
      dir = nodes[j].pos.copy().sub(nodes[i].pos)
      force = dir.div(dir.mag() * dir.mag())
      force.mult(forceConstant)
      nodes[i].force.add(force.copy().mult(-1))
      nodes[j].force.add(force)
    }
  }

  nodes.forEach(node => {
    gravity = node.pos.copy().mult(-0.01).mult(gravityConstant)
    node.force.add(gravity)
    let ang = atan2(node.pos.y, node.pos.x) + PI / 2;
    let rot = createVector(cos(ang), sin(ang)).mult(rotationalConstant);
    node.force.add(rot);
    node.force.add(node.vel.copy().mult(-0.8));
  })

  particles.forEach(particle => {
    let dir = particle.target.pos.copy().sub(particle.pos)
    if (dir.mag() > particle.target.mass / 2) {
      let attract = dir.copy().div(dir.mag() * dir.mag())
      particle.force.add(attract)
    } else {
      let repulse = dir.copy().div(dir.mag() * dir.mag() * dir.mag())
      particle.force.add(repulse.mult(-1))
    }
    particle.force.add(particle.vel.copy().mult(-0.01))
  })
}

class Node {
  constructor(pos, size) {
    this.pos = pos;
    this.force = createVector(0, 0);
    this.vel = createVector(0, 0);
    this.mass = (2 * PI * size) / 1.5;
  }

  update() {
    this.vel.add(this.force.div(this.mass))
    this.pos.add(this.vel)
    this.force.set(0, 0)
  }
}

class Particle {
  constructor(target) {
    this.target = target;
    let ang = random(TWO_PI)
    this.pos = this.target.pos.copy();
    this.pos.x += this.target.mass * cos(ang)
    this.pos.y += this.target.mass * sin(ang)
    this.vel = createVector(0, 0)
    this.force = createVector(0, 0)
  }

  update() {
    this.vel.add(this.force)
    this.vel.limit(2)
    this.pos.add(this.vel)
    this.force.set(0, 0)

    let closeEdge = false;
    connections.forEach(conn => {
      let node1 = nodes[conn[0]];
      let node2 = nodes[conn[1]];
      let edgeDir = node2.pos.copy().sub(node1.pos);
      let edgeLength = edgeDir.mag();
      edgeDir.normalize();
      let proj = p5.Vector.sub(this.pos, node1.pos).dot(edgeDir);
      if (proj > 0 && proj < edgeLength) {
        let closestPoint = p5.Vector.add(node1.pos, edgeDir.mult(proj));
        let distToEdge = p5.Vector.dist(this.pos, closestPoint);
        if (distToEdge < this.target.mass) {
          this.force.add(p5.Vector.sub(closestPoint, this.pos).mult(0.1));
          closeEdge = true;
        }
      }
    });

    if (!closeEdge) {
      let dir = this.target.pos.copy().sub(this.pos);
      if (dir.mag() > this.target.mass / 2) {
        let attract = dir.copy().div(dir.mag() * dir.mag());
        this.force.add(attract);
      } else {
        let repulse = dir.copy().div(dir.mag() * dir.mag() * dir.mag());
        this.force.add(repulse.mult(-1));
      }
    }

    if (random(1) < 0.01) {
      let targetChanged = false;
      for (let i = 0; i < 10; i++) {
        let conn = random(connections);
        if (conn) {
          let node1 = nodes[conn[0]];
          let node2 = nodes[conn[1]];
          if (node1 == this.target) {
            this.target = node2;
            let brake = this.vel.copy().mult(-0.5);
            this.vel.add(brake);
            targetChanged = true;
            break;
          } else if (node2 == this.target) {
            this.target = node1;
            let brake = this.vel.copy().mult(-0.5);
            this.vel.add(brake);
            targetChanged = true;
            break;
          }
        }
      }
      if (!targetChanged && random() < 0.01) {
        let conn = random(connections);
        if (conn) {
          this.target = nodes[conn[0]];
          let brake = this.vel.copy().mult(-0.5);
          this.vel.add(brake);
        }
      }
    }
  }
}

function loadForm() {
  insertForm.innerHTML = `
    
<section class="container cards-form-style">
<div class="container" style="padding: 1rem; padding-left: 2rem; padding-right: 2rem;">
  <h5 >CONNECT:</h5>
  <form action="">
    <div class="row">
      <div class="col-lg-5 col-sm-12">
        <input class="input-form" type="text" placeholder="Name" id="input1">
      </div>
      <div class="col-lg-1 col-sm-12 text-center" style="padding-top: 2rem;">
        to
      </div>
      <div class="col-lg-5 col-sm-12">
        <input class="input-form" type="text" placeholder="Name" id="input2">
      </div>
    </div>
    <div class="row">
      <div class="alert alert-danger fade show col-lg-5 col-sm-12 text-center" style="display:none;" role="alert"
        id="alertV">
        <p id="alertT"></p>
      </div>
    </div>
    <button type="button" class="btn" id="btn">Create</button>
  </form>
</div>
</section>

`;

}

function initBtn() {
  btn.addEventListener("click", function (event) {
    event.preventDefault();
    alertT.innerHTML = ``;
    alertV.style.display = "none";
    name1.style.border = "solid 0.2rem #F3F5F0";
    name2.style.border = "solid 0.2rem #F3F5F0";
    isValid = true;
    match = true;
    if ((name1.value.length < 3) || !blankRegex.test(name1.value)) {
      alertT.innerHTML += `<p><b style="color: red;">Name</b> input is invalid.</p>`;
      alertV.style.display = "block";
      name1.style.border = "solid red medium";
      isValid = false;
    }

    if ((name2.value.length < 3) || !blankRegex.test(name2.value)) {
      alertT.innerHTML += `<p><b style="color: red;">Name</b> input is invalid.</p>`;
      alertV.style.display = "block";
      name2.style.border = "solid red medium";
      isValid = false;
    }

    jsonData.nodes.forEach((n) => {
      if (n.name == name1.value && match) {
        jsonData.nodes.forEach((m) => {
          if (m.name == name2.value && match) {
            //"Both nicknames saved."
            jsonData.connections.forEach((w) => {
              if ((n.id == w.source) && (m.id == w.target) && match) {
                //"Connection exists."
                alertT.innerHTML += `<p>Connection Exists.</p>`;
                alertV.style.display = "block";
                name1.style.border = "solid red medium";
                name2.style.border = "solid red medium";
                match = false;
                isValid = false;
              } else if ((m.id == w.source) && (n.id == w.target) && match) {
                //"Connection exists."
                alertT.innerHTML += `<p>Connection Exists.</p>`;
                alertV.style.display = "block";
                name1.style.border = "solid red medium";
                name2.style.border = "solid red medium";
                match = false;
                isValid = false;
              }
            });
            if (match) {
              //"Both nicknames saved."
              jsonData.connections.push({
                "source": n.id,
                "target": m.id,
                "distance": parseInt(dist(n.x, n.y, m.x, m.y))
              });
              match = false;
            }
          }
        });
      } else if (n.name == name2.value && match) {
        jsonData.nodes.forEach((m) => {
          if (m.name == name1.value && match) {
            jsonData.connections.forEach((w) => {
              if ((n.id == w.source) && (m.id == w.target) && match) {
                //"Connection exists."
                alertT.innerHTML += `<p>Connection Exists.</p>`;
                alertV.style.display = "block";
                name1.style.border = "solid red medium";
                name2.style.border = "solid red medium";
                match = false;
                isValid = false;
              } else if ((m.id == w.source) && (n.id == w.target) && match) {
                //"Connection exists."
                alertT.innerHTML += `<p>Connection Exists.</p>`;
                alertV.style.display = "block";
                name1.style.border = "solid red medium";
                name2.style.border = "solid red medium";
                match = false;
                isValid = false;
              }
            });
            if (match) {
              //"Both nicknames saved."
              let d = random(minConnectionLength, maxConnectionLength);
              jsonData.connections.push({
                "source": m.id,
                "target": n.id,
                "distance": d
              });
              addConnection(m.id + 1, n.id + 1, d);
              match = false;
            }
          }
        });
      }

      if (n.name == name1.value && match) {
        //"Only nickname 1 saved."
        let x2 = parseInt(random(-100, 100));
        let y2 = parseInt(random(-100, 100));
        let s2 = parseInt(random(1, 5));
        let d = random(minConnectionLength, maxConnectionLength);
        jsonData.connections.push({
          "source": n.id,
          "target": jsonData.nodes.length,
          "distance": d
        });
        jsonData.nodes.push({
          "id": jsonData.nodes.length,
          "name": name2.value,
          "x": x2,
          "y": y2,
          "size": s2
        });
        addNode(x2, y2, s2);
        addConnection(n.id + 1, jsonData.nodes.length, d);
        match = false;
      } else if (n.name == name2.value && match) {
        //"Only nickname input 2 saved."
        let x1 = parseInt(random(-100, 100));
        let y1 = parseInt(random(-100, 100));
        let s1 = parseInt(random(1, 5));
        let d = random(minConnectionLength, maxConnectionLength);
        jsonData.connections.push({
          "source": jsonData.nodes.length,
          "target": n.id,
          "distance": d
        });
        jsonData.nodes.push({
          "id": jsonData.nodes.length,
          "name": name1.value,
          "x": x1,
          "y": y1,
          "size": s1
        });
        addNode(x1, y1, s1);
        addConnection(jsonData.nodes.length, n.id + 1, d);
        match = false;
      }
    });

    if (match && isValid) {
      //"Both nicknames not saved."
      let x1 = parseInt(random(-100, 100));
      let y1 = parseInt(random(-100, 100));
      let x2 = parseInt(random(-100, 100));
      let y2 = parseInt(random(-100, 100));
      let s1 = parseInt(random(1, 5));
      let s2 = parseInt(random(1, 5));
      let d = random(minConnectionLength, maxConnectionLength);
      jsonData.connections.push({
        "source": jsonData.nodes.length,
        "target": jsonData.nodes.length + 1,
        "distance": d
      });
      jsonData.nodes.push({
        "id": jsonData.nodes.length,
        "name": name1.value,
        "x": x1,
        "y": y1,
        "size": s1
      });
      addNode(x1, y1, s1);
      jsonData.nodes.push({
        "id": jsonData.nodes.length,
        "name": name2.value,
        "x": x2,
        "y": y2,
        "size": s2
      });
      addNode(x2, y2, s2);
      addConnection(jsonData.nodes.length - 1, jsonData.nodes.length, d);
      match = false;
    }

    if (isValid) {
      insertForm.innerHTML = ``;
      toggle = false;

      alertT.innerHTML = ``;
      alertV.style.display = "none";
      name1.style.border = "solid 0.2rem #F3F5F0";
      name1.value = '';
      name2.style.border = "solid 0.2rem #F3F5F0";
      name2.value = '';
    }

  });
}