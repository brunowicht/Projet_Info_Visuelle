import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import processing.core.PImage;
import processing.core.PVector;


public class Hough {
	

	private float StepsPhi = 0.06f;
	private float StepsR   = 2.5f;
	
	private int phi;
	private int rDim;
	private float rMax;
	
	private Map<Integer, Line> lines = new HashMap<>();
	
	
	
	public Hough(List<Line> l, int phiDim, int rDim, float rMax){
		for(Line line : l)  lines.put(line.indice(), line); 
		this.rMax   = rMax;
		this.phi=  rDim;
		this.rDim   =  rDim;
	}
	
	
	
	
	public Hough(PImage img){
		
		this.rMax   = (img.width + img.height) * 2 + 1;
		this.phi = (int)(    Math.PI / StepsPhi  );
		this.rDim   = (int)(    rMax / StepsR       );
		
		
		for (int y = 0; y < img.height; y++) for (int x = 0; x < img.width; x++) 
		if ((img.pixels[y * img.width + x] & 0xFF) != 0) {

					float phiInter = 0;
            int accPhi = 0;
					
					while(phiInter < Math.PI){
						
					float r = (float)(x * Math.cos(phiInter) + y * Math.sin(phiInter));
					int accR = (int) Math.round(r / StepsR) + (rDim - 1) / 2;
					int ind = (accPhi + 1) * (rDim + 2) + accR + 1;
					
					
					if( !lines.containsKey(ind) ) lines.put(ind, new Line(accPhi, phiInter, accR, r, rDim));
					
					lines.get(ind).addVote();
					
					
					phiInter += StepsPhi;
                        accPhi++;
					
					}
					
		}
		
		

	}
	

	
	
	public Hough filter(int voteThreshold){
		
		List<Line> filteredlines = new ArrayList<>();
		
		for(Line line : lines.values()) if( line.votes() > voteThreshold){
			filteredlines.add(line);
		}
		
		return new Hough(filteredlines, phi, rDim, rMax);
	}
	
	
	
	
	
	public Hough takeBest(int value){
		List<Line> reverseSortedLines = lines();
		Collections.sort(reverseSortedLines);
		Collections.reverse(reverseSortedLines);
		List<Line> requestedLines = new ArrayList<>();
		
		for(int i = 0; i< value; i++)
		if(i < reverseSortedLines.size())
		requestedLines.add(reverseSortedLines.get(i));
		
		return new Hough(requestedLines, phi, rDim, rMax);
	}
	
	
	

public Hough neighbourhoodFilter(){
	
	
	int[] accumulator = new int[(phi2)*(rDim+2)];
	
	for(int i = 0; i< accumulator.length; i++)
		accumulator[i] = 0;
	
	for(Line line : lines()) accumulator[line.indice()] = line.votes();
	
	
	List<Line> bestCandidates = new ArrayList<>();

	int neighbourhood = 10;

	int minVotes = 100;

	for(int accR = 0; accR < rDim; accR++){
	for(int accPhi = 0; accPhi < phi; accPhi++){

	int idx = (accPhi + 1) * (rDim + 2) + accR +1;

	if(accumulator[idx] > minVotes){

        boolean bestCandidate = true;

	for(int dPhi = -neighbourhood/2; dPhi < neighbourhood/2 + 1; dPhi++){
	if(accPhi + dPhi < 0 || accPhi + dPhi >= phi) continue;

	for(int dR = - neighbourhood/2; dR < neighbourhood/2 + 1; dR++){
	if(accR + dR < 0 || accR + dR >= rDim) continue;

	
	int neighbourIdx = (accPhi + dPhi + 1) * (rDim + 2) + accR + dR + 1; 

	if(accumulator[idx] < accumulator[neighbourIdx]){
	bestCandidate = false;
	break;
	}


	}

	if(!bestCandidate) break;

	}

	if(bestCandidate) bestCandidates.add(lines.get(idx));

	}

	}
	}
	
	return new Hough(bestCandidates, phi, rDim, rMax);
}

	
	
	
	
	public List<PVector> vectlines(){
		
		 List<PVector> vectLines = new ArrayList<>();
		 
		 for(Line line : lines.values()) vectLines.add(line.toVect());
		 
		 return vectLines;
	}
	
	
	
	
	
	public PImage image(){

	     PImage houghImg = new PImage(rDim + 2, phi + 2);
	     
	     for(int i = 0; i< houghImg.height * houghImg.width; i++) if(lines.containsKey(i))
	     houghImg.pixels[i] = Math.min( 255, lines.get(i).votes() );   
	     
	     houghImg.updatePixels();
	     
	     return houghImg;
	}
	
	

	
	public List<Line> lines(){
		
	     return new ArrayList<>(lines.values());
	     
	}
	
	
	
	
	
	
	
	
}
