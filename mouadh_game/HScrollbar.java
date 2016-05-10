package cs211.tangiblegame;

import processing.core.PApplet;

public class HScrollbar {
	PApplet parent;
    float sliderPos, newSliderPos;
    float sliderPosMin, sliderPosMax;
    boolean mouseOver;
    boolean locked;
    float largeurDuBar;
	float longuerDuBar;
	float xPos;
	float yPos;



	HScrollbar(PApplet p, float x, float y, float w, float h) {
		parent = p;
		largeurDuBar = w;
		longuerDuBar = h;
		xPos = x;
		yPos = y;
		sliderPos = xPos + largeurDuBar / 2 - longuerDuBar / 2;
		newSliderPos = sliderPos;
		sliderPos = xPos;
		sliderPos = xPos + largeurDuBar - longuerDuBar;
	}

	
	void update() {
		if (isMouseOver()) {
			mouseOver = true;
		} else {
			mouseOver = false;
		}
		if (parent.mousePressed && mouseOver) {
			locked = true;
		}
		if (!parent.mousePressed) {
			locked = false;
		}
		if (locked) {
			newSliderPos = constrain(parent.mouseX - largeurDuBar / 2,
					sliderPosMin, sliderPosMax);
		}
		if (parent.abs(newSliderPos - sliderPos) > 1) {
			sliderPos = sliderPos
					+ (newSliderPos - sliderPos);
		}
	}


	float constrain(float val, float minVal, float maxVal) {
		return parent.min(parent.max(val, minVal), maxVal);
	}

	
	boolean isMouseOver() {
		if (parent.mouseX > xPos && parent.mouseX < xPos + largeurDuBar
				&& parent.mouseY > yPos && parent.mouseY < yPos + longuerDuBar) {
			return true;
		} else {
			return false;
		}
	}

	
	void display() {
		parent.noStroke();
		parent.fill(204);
		parent.rect(xPos, yPos, largeurDuBar, longuerDuBar);
		if (mouseOver || locked) {
			parent.fill(0, 0, 0);
		} else {
			parent.fill(102, 102, 102);
		}
		parent.rect(sliderPosition, yPosition, largeurDuBar, longuerDuBar);
	}


	float getPos() {
		return (sliderPos - xPos) / (largeurDuBar - longuerDuBar);
	}
}