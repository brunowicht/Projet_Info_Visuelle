import java.util.ArrayList;
import java.util.List;

import processing.core.PVector;



class Line implements Comparable<Line>{
		
	
		
		public final float r;
		public final float alpha ;
		public final int rd;
		private int votes;
       public final int accangulaire ;
       public final int accR;
		
		
		public Line(int accangulaire, float alpha, int accR, float r, int rd ){
			
			this.accangulaire = accangulaire;
			this.accR = accR;
			this.r = r;
			this.alpha = alpha;
			this.rd = rd;
            this.votes = 0;
		}
		
		
		
		
		public static int index(intaccangulaire, int accR, int rd){
			return (accangulaire + 1) * (rd + 2) + accR + 1;
		}

		
		public int index(){	return (accangulaire + 1) * (rd + 2) + accR + 1;		}
		
		public int votes(){  return votes; }
		
		
		@Override
		public int compareTo(Line that) {
            if(this.votes > that.votes) {
                return 1;
            }
            else if(this.votes == that.votes){
                return 0;
            }
            else{
                return -1;
            }
		}	
		
		
		

		
public static List<PVector> getIntersections(List<Line> lines){
			
			List<PVector> intersec =  new ArrayList<PVector>();
			Line l1, l2;
			
			for(int i = 0; i < lines.size(); i++){
                l1 = lines.get(i);
				for(int j = i+1; j < lines.size(); j++){
                l2 =  lines.get(j);
				double d = Math.cos(l2.alpha)*Math.sin(l1.alpha) - Math.cos(l1.alpha)*Math.sin(l2.alpha);
				double x =  ( l2.r*Math.sin(l1.alpha) - l1.r*Math.sin(l2.alpha) )/d;
				double y =  (-l2.r*Math.cos(l1.alpha) + l1.r*Math.cos(l2.alpha) )/d;
				intersec.add( new PVector((int)x,(int)y));
				}	
			}
			return intersec;
		}

public static PVector intersections(PVector l1, PVector l2){
		
	double d = Math.cos(l2.y)*Math.sin(l1.y) - Math.cos(l1.y)*Math.sin(l2.y);
	double x =  ( l2.x*Math.sin(l1.y) - l1.x*Math.sin(l2.y) )/d;
	double y =  (-l2.x*Math.cos(l1.y) + l1.x*Math.cos(l2.y) )/d;
		
		return new PVector((int)x,(int)y)  ;
	
}
		
	
		
	public static class CartesianLine{
			
			public final float x1, y1, x2, y2;
			
			public CartesianLine(float x1, float y1, float x2, float y2){
				this.x1 = x1;
                this.x2 = x2;
				this.y1 = y1;
                this.y2 = y2;
			}
			
		}
		
	
	
		
		public CartesianLine lineThroughScreen( int width, int height){
			
			CartesianLine line;
			int x0 = 0;
			int y0 = (int) (r/Math.sin(alpha));
			int x1 = (int) (r/Math.cos(alpha));
			int y1 = 0;
			int x2 = width;
			int y2 = (int)(-Math.cos(alpha) / Math.sin(alpha) * x2 + r/Math.sin(alpha));
			int y3 = width;
			int x3 = (int) ( -( y3 - r/Math.sin(alpha)) * (Math.sin(alpha) / Math.cos(alpha) ) ) ;
			
            if(y0 > 0) {
                if (x1 > 0) 	{
                    
                line = new CartesianLine(x0,y0,x1,y1);
                }
                else if(y2 > 0){
                    
                line = new CartesianLine(x0,y0,x2,y2);
                }
                else{
                    
                    line = new CartesianLine(x0,y0,x3,y3);}
            }
            else{
                if (x1 > 0) {
                    if(y2 > 0) {
                        line = new CartesianLine(x1,y1,x2,y2);
                    }
                    else		{
                        line = new CartesianLine(x1,y1,x3,y3);
                    }
                    else		{
                        line = new CartesianLine(x2,y2,x3,y3);
                    }
			
			
			return line;
		}
		
		
		
		
	}
	
	
	
	
	