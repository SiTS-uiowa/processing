class Vec2 {
  float x;
  float y;
  
  Vec2(float aX, float aY) {
   x = aX;
   y = aY;
  }
  
  Vec2 normalized() {
    float m = sqrt(this.x * this.x + this.y * this.y);
    if (m != 0) {
      return new Vec2(this.x / m, this.y / m);
    } else {
      return new Vec2(this.x, this.y);
    }
  }
  
  void normalize() {
    float m = sqrt(this.x * this.x + this.y * this.y);
    if (m != 0) {
      this.x /= m;
      this.y /= m;
    }
  }
  
  Vec2 plus(Vec2 other) {
    return new Vec2(this.x + other.x, this.y + other.y);
  }
  
  float sqrDistance(Vec2 other) {
    Vec2 d = new Vec2(other.x - this.x, other.y - this.y);
    return d.x * d.x + d.y * d.y;
  }
  
  float distance(Vec2 other) {
    return sqrt(this.sqrDistance(other));
  }
  
  Vec2 scale(float s) {
    this.x *= s;
    this.y *= s;
    return this;
  }
}

class Boid {
  Vec2 pos;
  Vec2 vel;
  Vec2 acc;
  
  boolean isNeighbor(Boid other) {
    if (other == this) {
      return false;
    }
    if (this.pos.distance(other.pos) < distanceRequirement) {
      return true;
    }
    
    return false;
  }
  
  Boid() {
    pos = new Vec2(random(0, width), random(0, height));
    vel = (new Vec2(random(-10, 10), random(-10, 10))).normalized();
    acc = new Vec2(0, 0);
  }
  
  float distanceFrom(Boid other) {
    return this.pos.distance(other.pos);
  }
  
  Vec2 computeAlignment() {
    Vec2 alignment = new Vec2(0, 0);
    
    for (int i = 0; i < num; i++) {
      Boid other = boids[i];
      if (this.isNeighbor(other)) {
        alignment = alignment.plus(other.vel);
      }
    }
    
    alignment.normalize();
    return alignment;
  }
  
  Vec2 computeCohesion() {
    Vec2 cohesion = new Vec2(0, 0);
    for (int i = 0; i < num; i++) {
      Boid other = boids[i];
      if (this.isNeighbor(other)) {
        cohesion = cohesion.plus(other.pos);
      }
    }
    cohesion = new Vec2(cohesion.x - this.pos.x, cohesion.y - this.pos.y);
    
    cohesion.normalize();
    return cohesion;
  }
  
  Vec2 computeSeparation() {
    Vec2 separation = new Vec2(0, 0);
    for (int i = 0; i < num; i++) {
      Boid other = boids[i];
      if (this.isNeighbor(other)) {
        separation = separation.plus(new Vec2(this.pos.x - other.pos.x, this.pos.y - other.pos.y));
      }
    }
    
    separation.normalize();
    return separation;
  }
  
  void update() {
    Vec2 alignment = this.computeAlignment().scale(ALIGNMENT_WEIGHT);
    Vec2 cohesion = this.computeCohesion().scale(COHESION_WEIGHT);
    Vec2 separation = this.computeSeparation().scale(SEPARATION_WEIGHT);
    this.acc = this.acc.plus(alignment).plus(cohesion).plus(separation);
    
    this.acc.normalize();
    this.acc.scale(ACCELERATION_WEIGHT);
    
    this.vel = this.vel.plus(this.acc).normalized().scale(boidSpeed);
    this.pos = this.pos.plus(this.vel);
    
    if (this.pos.x > width) {
      this.pos.x = 0;
    }
    if (this.pos.x < 0) {
      this.pos.x = width;
    }
    if (this.pos.y > height) {
      this.pos.y = 0;
    }
    if (this.pos.y < 0) {
      this.pos.y = height;
    }
  }
  
  void draw() {
    update();
    ellipse(pos.x, pos.y, 10, 10); 
  }
}

int num = 50;
int distanceRequirement = 50;
Boid[] boids = new Boid[num];
float boidSpeed = 3;

float ALIGNMENT_WEIGHT = 0.2;
float COHESION_WEIGHT = 0.4;
float SEPARATION_WEIGHT = 0.4;
float ACCELERATION_WEIGHT = 0.5;

void setup() {
  size(1024, 1024);
  
  for(int i = 0; i < num; i++) {
    boids[i] = new Boid(); 
  }
}

void draw() {
  background(153);
  for(int i = 0; i < num; i++) {
    boids[i].draw();
  }
}
