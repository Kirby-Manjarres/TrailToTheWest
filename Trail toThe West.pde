// Trail to the West - A retro-style Oregon Trail-inspired game in Processing
// Player manages a pioneer party, makes decisions, and survives random events
// Enhanced with pixel-art backgrounds, improved deer sprite with animation

// Game states
final int STATE_MENU = 0;
final int STATE_TRAVEL = 1;
final int STATE_EVENT = 2;
final int STATE_HUNT = 3;
int gameState = STATE_MENU;

// Party and resources
class PartyMember {
  String name;
  int health; // 0-100
  int morale; // 0-100
  
  PartyMember(String n, int h, int m) {
    name = n;
    health = h;
    morale = m;
  }
}
ArrayList<PartyMember> party = new ArrayList<PartyMember>();
int food = 500; // Pounds
int ammo = 100; // Rounds
int medicine = 10; // Doses
int wagonParts = 5; // Spare parts
int distanceTraveled = 0;
int totalDistance = 2000; // Miles to Oregon
int day = 1;

// Milestones
String[] milestones = {"Independence", "Fort Kearny", "Chimney Rock", "Independence Rock", "Fort Bridger", "Oregon"};
int[] milestoneDistances = {0, 300, 700, 1000, 1400, 2000};
int currentMilestone = 0;

// Event system
String currentEvent = "";
String[] eventOptions = new String[2];
String eventOutcome = "";
float eventChance = 0.3; // 30% chance per day for an event

// Hunting mini-game
int huntTimer = 0;
int huntTargetX, huntTargetY;
float huntTargetSpeed; // Varies per deer
int huntTargetDirection = 1; // 1 = right, -1 = left (retreat)
float retreatPoint; // X position where deer may retreat
boolean huntHit = false;
int huntScore = 0;

// Menu selection
int selectedOption = 0;
String[] menuOptions = {"Travel", "Rest", "Hunt", "Trade", "Inventory"};

// Visual settings
PFont pixelFont;
PImage bgMenu, bgTravel, bgEvent, bgHunt, parchment, border, deer, deer1, deer2;

void setup() {
  size(800, 600);
  // Create pixel-art font (approximated with a monospaced font)
  pixelFont = createFont("Courier New", 16);
  textFont(pixelFont);
  textAlign(LEFT, TOP);
  
  // Initialize party
  party.add(new PartyMember("John", 100, 80));
  party.add(new PartyMember("Mary", 90, 85));
  party.add(new PartyMember("Tom", 95, 75));
  party.add(new PartyMember("Sarah", 85, 90));
  
  // Initialize hunting target
  huntTargetX = 0;
  huntTargetY = (int)random(100, 500);
  huntTargetSpeed = random(3, 7); // Random speed between 3 and 7 pixels/frame
  retreatPoint = random(width * 0.5, width * 0.8); // Random retreat point
  
  // Load images (place in 'data' folder)
  bgMenu = loadImage("background_menu.png");
  bgTravel = loadImage("background_travel.png");
  bgEvent = loadImage("background_event.png");
  bgHunt = loadImage("background_hunt.png");
  parchment = loadImage("parchment.png");
  border = loadImage("border.png");
  deer = loadImage("deer.png"); // Single sprite fallback
  deer1 = loadImage("deer1.png"); // Animation frame 1
  deer2 = loadImage("deer2.png"); // Animation frame 2
}

void draw() {
  // Draw background based on game state
  if (gameState == STATE_MENU) {
    if (bgMenu != null) {
      image(bgMenu, 0, 0);
    } else {
      background(50, 100, 50); // Fallback: green prairie
    }
    drawMenu();
  } else if (gameState == STATE_TRAVEL) {
    if (bgTravel != null) {
      image(bgTravel, 0, 0);
    } else {
      background(50, 100, 50); // Fallback: green trail
    }
    drawTravel();
  } else if (gameState == STATE_EVENT) {
    if (bgEvent != null) {
      image(bgEvent, 0, 0);
    } else {
      background(200, 150, 100); // Fallback: parchment brown
    }
    drawEvent();
  } else if (gameState == STATE_HUNT) {
    if (bgHunt != null) {
      image(bgHunt, 0, 0);
    } else {
      background(34, 139, 34); // Fallback: forest green
    }
    drawHunt();
  }
  
  // Draw status bar
  drawStatusBar();
}

void drawMenu() {
  // Draw title with shadow
  textSize(24);
  fill(0); // Shadow
  text("Trail to the West - Day " + day, 22, 22);
  text("Next Milestone: " + milestones[currentMilestone + 1] + " (" + (milestoneDistances[currentMilestone + 1] - distanceTraveled) + " miles)", 22, 52);
  fill(255); // White text
  text("Trail to the West - Day " + day, 20, 20);
  text("Next Milestone: " + milestones[currentMilestone + 1] + " (" + (milestoneDistances[currentMilestone + 1] - distanceTraveled) + " miles)", 20, 50);
  
  // Draw menu options
  textSize(16);
  for (int i = 0; i < menuOptions.length; i++) {
    if (i == selectedOption) {
      fill(0); // Shadow
      text((i + 1) + ". " + menuOptions[i], 22, 102 + i * 30);
      fill(255, 255, 0); // Highlight selected
      text((i + 1) + ". " + menuOptions[i], 20, 100 + i * 30);
    } else {
      fill(0); // Shadow
      text((i + 1) + ". " + menuOptions[i], 22, 102 + i * 30);
      fill(255); // White
      text((i + 1) + ". " + menuOptions[i], 20, 100 + i * 30);
    }
  }
}

void drawTravel() {
  // Draw travel info with shadow
  textSize(24);
  fill(0); // Shadow
  text("Traveling... Day " + day, 22, 22);
  text("Distance: " + distanceTraveled + "/" + totalDistance + " miles", 22, 52);
  fill(255); // White
  text("Traveling... Day " + day, 20, 20);
  text("Distance: " + distanceTraveled + "/" + totalDistance + " miles", 20, 50);
  
  // Simulate travel
  distanceTraveled += 15; // 15 miles per day
  food -= party.size() * 3; // 3 pounds per person per day
  updatePartyStatus();
  
  // Check for milestone
  if (distanceTraveled >= milestoneDistances[currentMilestone + 1]) {
    currentMilestone++;
    if (currentMilestone + 1 >= milestones.length) {
      textSize(24);
      fill(0); // Shadow
      text("You reached Oregon! Game Over!", 22, 202);
      fill(255); // White
      text("You reached Oregon! Game Over!", 20, 200);
      noLoop();
      return;
    }
  }
  
  // Random event chance
  if (random(1) < eventChance) {
    triggerRandomEvent();
    gameState = STATE_EVENT;
  } else {
    day++;
    gameState = STATE_MENU;
  }
}

void drawEvent() {
  // Draw border
  if (border != null) {
    image(border, 20, 100);
  } else {
    fill(150, 100, 50); // Fallback: wooden brown
    rect(20, 100, 760, 200);
  }
  
  // Draw event text with shadow
  textSize(16);
  fill(0); // Shadow
  text(currentEvent, 24, 104, 752, 192);
  fill(255); // White
  text(currentEvent, 20, 100, 760, 200);
  
  for (int i = 0; i < eventOptions.length; i++) {
    if (i == selectedOption) {
      fill(0); // Shadow
      text((i + 1) + ". " + eventOptions[i], 24, 304 + i * 30);
      fill(255, 255, 0); // Highlight
      text((i + 1) + ". " + eventOptions[i], 20, 300 + i * 30);
    } else {
      fill(0); // Shadow
      text((i + 1) + ". " + eventOptions[i], 24, 304 + i * 30);
      fill(255); // White
      text((i + 1) + ". " + eventOptions[i], 20, 300 + i * 30);
    }
  }
  
  fill(0); // Shadow
  text(eventOutcome, 24, 404, 752, 92);
  fill(255); // White
  text(eventOutcome, 20, 400, 760, 100);
}

void drawHunt() {
  // Draw hunt info with shadow
  textSize(24);
  fill(0); // Shadow
  text("Hunting - Time: " + (30 - huntTimer), 22, 22);
  text("Score: " + huntScore, 22, 52);
  fill(255); // White
  text("Hunting - Time: " + (30 - huntTimer), 20, 20);
  text("Score: " + huntScore, 20, 50);
  
  // Move deer
  huntTargetX += huntTargetSpeed * huntTargetDirection;
  
  // Check for retreat
  if (huntTargetDirection == 1 && huntTargetX >= retreatPoint && random(1) < 0.3) {
    huntTargetDirection = -1; // 30% chance to retreat at retreat point
  }
  
  // Reset deer if it goes off-screen
  if (huntTargetX > width || huntTargetX < 0) {
    huntTargetX = 0;
    huntTargetY = (int)random(100, 500); // New random Y position
    huntTargetSpeed = random(3, 7); // New random speed
    huntTargetDirection = 1; // Move right again
    retreatPoint = random(width * 0.5, width * 0.8); // New retreat point
    huntTimer = 0;
    huntHit = false;
  }
  
  // Draw deer sprite with animation
  PImage deerFrame;
  if (deer1 != null && deer2 != null) {
    // Animation: alternate frames every 15 frames (0.25s at 60fps)
    deerFrame = (huntTimer % 30 < 15) ? deer1 : deer2;
  } else if (deer != null) {
    // Single sprite fallback
    deerFrame = deer;
  } else {
    // Ultimate fallback: brown circle
    fill(139, 69, 19);
    ellipse(huntTargetX, huntTargetY, 20, 20);
    deerFrame = null;
  }
  
  if (deerFrame != null) {
    pushMatrix();
    translate(huntTargetX, huntTargetY);
    if (huntTargetDirection == -1) {
      scale(-1, 1); // Flip horizontally for retreat
      image(deerFrame, -48, -24); // Adjust for 48x48 sprite
    } else {
      image(deerFrame, -24, -24); // Center sprite
    }
    popMatrix();
  }
  
  // Crosshair
  stroke(255, 0, 0);
  line(mouseX - 10, mouseY, mouseX + 10, mouseY);
  line(mouseX, mouseY - 10, mouseX, mouseY + 10);
  noStroke();
  
  // Timer
  huntTimer++;
  if (huntTimer >= 30) { // 30 frames = ~0.5 seconds at 60fps
    huntTimer = 0;
  }
}

void drawStatusBar() {
  // Draw parchment background
  if (parchment != null) {
    image(parchment, 0, 500);
  } else {
    fill(200, 150, 100); // Fallback: parchment brown
    rect(0, 500, 800, 100);
  }
  
  // Draw status text with shadow
  textSize(14);
  fill(0); // Shadow
  text("Food: " + food + " lbs | Ammo: " + ammo + " | Medicine: " + medicine + " | Wagon Parts: " + wagonParts, 22, 512);
  text("Party: ", 22, 532);
  for (int i = 0; i < party.size(); i++) {
    PartyMember p = party.get(i);
    text(p.name + " (H:" + p.health + ", M:" + p.morale + ")", 22 + i * 150, 552);
  }
  fill(255); // White
  text("Food: " + food + " lbs | Ammo: " + ammo + " | Medicine: " + medicine + " | Wagon Parts: " + wagonParts, 20, 510);
  text("Party: ", 20, 530);
  for (int i = 0; i < party.size(); i++) {
    PartyMember p = party.get(i);
    text(p.name + " (H:" + p.health + ", M:" + p.morale + ")", 20 + i * 150, 550);
  }
}

void updatePartyStatus() {
  for (int i = 0; i < party.size(); i++) {
    PartyMember p = party.get(i);
    if (food <= 0) {
      p.health -= 5; // Starvation
      p.morale -= 10;
    }
    p.morale = constrain(p.morale - 2, 0, 100); // Daily morale decay
    p.health = constrain(p.health, 0, 100);
    
    if (p.health <= 0) {
      // Party member dies
      currentEvent = p.name + " has died!";
      eventOptions[0] = "Continue";
      eventOptions[1] = "";
      eventOutcome = "";
      party.remove(p);
      gameState = STATE_EVENT;
      break;
    }
  }
  if (party.size() == 0) {
    textSize(24);
    fill(0); // Shadow
    text("All party members died! Game Over!", 22, 202);
    fill(255); // White
    text("All party members died! Game Over!", 20, 200);
    noLoop();
  }
}

void triggerRandomEvent() {
  int eventType = (int)random(3);
  if (eventType == 0) {
    // River crossing
    currentEvent = "You reach a river. It's deep and fast-moving.";
    eventOptions[0] = "Ford the river";
    eventOptions[1] = "Wait for better conditions";
    eventOutcome = "";
  } else if (eventType == 1) {
    // Illness
    PartyMember p = party.get((int)random(party.size()));
    currentEvent = p.name + " is sick with dysentery.";
    eventOptions[0] = "Use medicine";
    eventOptions[1] = "Rest and hope they recover";
    eventOutcome = "";
  } else {
    // Trader encounter
    currentEvent = "A trader offers to trade 100 lbs of food for 20 rounds of ammo.";
    eventOptions[0] = "Accept trade";
    eventOptions[1] = "Decline";
    eventOutcome = "";
  }
}

void handleEventChoice(int choice) {
  if (currentEvent.contains("river")) {
    if (choice == 0) { // Ford
      if (random(1) < 0.7) {
        eventOutcome = "You crossed successfully!";
      } else {
        eventOutcome = "The wagon broke! Lost 1 wagon part.";
        wagonParts--;
      }
    } else { // Wait
      eventOutcome = "You wait a day. Conditions improve.";
      day++;
      food -= party.size() * 3;
    }
  } else if (currentEvent.contains("dysentery")) {
    PartyMember p = null;
    for (PartyMember pm : party) {
      if (currentEvent.contains(pm.name)) {
        p = pm;
        break;
      }
    }
    if (p != null) {
      if (choice == 0 && medicine > 0) { // Use medicine
        medicine--;
        p.health += 20;
        eventOutcome = p.name + " feels better!";
      } else { // Rest
        if (random(1) < 0.5) {
          p.health += 10;
          eventOutcome = p.name + " recovers slightly.";
        } else {
          p.health -= 10;
          eventOutcome = p.name + "'s condition worsens.";
        }
        day++;
        food -= party.size() * 3;
      }
    }
  } else if (currentEvent.contains("trader")) {
    if (choice == 0 && ammo >= 20) { // Accept trade
      ammo -= 20;
      food += 100;
      eventOutcome = "Trade successful!";
    } else {
      eventOutcome = "Trade declined or not enough ammo.";
    }
  }
  gameState = STATE_MENU;
  selectedOption = 0;
}

void keyPressed() {
  if (gameState == STATE_MENU) {
    if (key == CODED) {
      if (keyCode == UP) {
        selectedOption = max(0, selectedOption - 1);
      } else if (keyCode == DOWN) {
        selectedOption = min(menuOptions.length - 1, selectedOption + 1);
      }
    } else if (key == ENTER || key == ' ') {
      if (selectedOption == 0) { // Travel
        gameState = STATE_TRAVEL;
      } else if (selectedOption == 1) { // Rest
        day++;
        food -= party.size() * 3;
        for (PartyMember p : party) {
          p.health = min(p.health + 10, 100);
          p.morale = min(p.morale + 15, 100);
        }
        gameState = STATE_MENU;
      } else if (selectedOption == 2) { // Hunt
        gameState = STATE_HUNT;
        huntTimer = 0;
        huntScore = 0;
        huntTargetX = 0;
        huntTargetY = (int)random(100, 500);
        huntTargetSpeed = random(3, 7); // Random speed for new deer
        huntTargetDirection = 1; // Start moving right
        retreatPoint = random(width * 0.5, width * 0.8); // Random retreat point
      } else if (selectedOption == 3) { // Trade
        currentEvent = "No traders nearby today.";
        eventOptions[0] = "Continue";
        eventOptions[1] = "";
        eventOutcome = "";
        gameState = STATE_EVENT;
      } else if (selectedOption == 4) { // Inventory
        currentEvent = "Inventory: Food: " + food + " lbs, Ammo: " + ammo + ", Medicine: " + medicine + ", Wagon Parts: " + wagonParts;
        eventOptions[0] = "Continue";
        eventOptions[1] = "";
        eventOutcome = "";
        gameState = STATE_EVENT;
      }
    }
  } else if (gameState == STATE_EVENT) {
    if (key == '1' || key == '2') {
      int choice = key == '1' ? 0 : 1;
      if (eventOptions[choice] != "") {
        handleEventChoice(choice);
      }
    }
  } else if (gameState == STATE_HUNT) {
    if (key == 'q' || key == 'Q') {
      food += huntScore; // Add earned food to inventory
      day++; // Increment day
      gameState = STATE_MENU; // Return to main menu
    }
  }
}

void mousePressed() {
  if (gameState == STATE_HUNT && ammo > 0) {
    ammo--;
    if (!huntHit && dist(mouseX, mouseY, huntTargetX, huntTargetY) < 30) { // Increased hit radius for 48x48 sprite
      huntScore += 50; // 50 lbs of food per hit
      huntHit = true;
      huntTargetX = 0;
      huntTargetY = (int)random(100, 500); // Reset to left with new Y
      huntTargetSpeed = random(3, 7); // New random speed
      huntTargetDirection = 1; // Move right again
      retreatPoint = random(width * 0.5, width * 0.8); // New retreat point
      huntTimer = 0;
    }
    if (ammo <= 0 || huntScore >= 200) {
      food += huntScore;
      day++;
      gameState = STATE_MENU; // Return to main menu
    }
  }
}
