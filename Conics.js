//program conics;

//const
 ZERO=0.0;
 HALF=0.5;
 ONE=1.0;
 BIGINTEGER=1024;
 BIGREAL=1024.0;
//type
// tpoint=record x,y,z: real end; point=^tpoint;
// line=point; //(* Duality! *)
 //(* Polar (line) is presented by its pole (point). See http://en.wikipedia.org/wiki/Pole_and_polar *)
var
 urx,ury, //(* The coordinates of the upper-right corner of the image. *)
 epsilon

function newpoint(x0,y0,z0) return {x:x0,y:y0,z:z0} //(* The constructor. *)

function plain(A) return newpoint(A.x/A.z,A.y/A.z,one) //(* Projects point on the drawing plane z=1. *)

function norm(A) return Math.abs(A.x) + Math.abs(A.y) + Math.abs(A.z) //(* The distance from (0,0,0). Any type of it. *)

function normed(A){ //(* Projects point on the unit sphere (or cube or octaedar). *)
 var r:=norm(A);
 if A.z<zero then r:=-r
 return newpoint(A.x/r,A.y/r,A.z/r)
}

function randominteger() //(* A random integer in the interval [0,1024). *)
 return Math.floor((Math.random()*biginteger)+1)

function randomreal()
// (* A random number in the interval (-1,1). Densest distribution around zero. *)
// (* A random number in the interval (0,1). Densest distribution of about 1/2. *)
// (* randomreal:=(randominteger-randominteger)/bigreal *)
 return half+half*(randominteger()-randominteger())/bigreal

function randompoint() //(* Random point in the plane (unit square). *)
 return normed(newpoint(randomreal,randomreal,one))

function scalar(A,p) //(* Dot product. Should be changed to distance(...). *)
 return A.x*p.x + A.y*p.y + A.z*p.z

function element(A,p) //(* Currently not used. *)
 return scalar(A,p)==zero

function vector(p1,p2)
(* Cross product. Base for any construction. *)
(* Returns the intersection point of two straight lines, and dual, line through the two points. *)
 return normed(newpoint(
  p1.y * p2.z - p1.z * p2.y,
  p1.z * p2.x - p1.x * p2.z,
  p1.x * p2.y - p1.y * p2.x))

function mixed(A,B,C) //(* Mixed product. *)
 return scalar(A,vector(B,C))

function area(A,B,C) //(* Area of triangle ABC. *)
 return Math.abs(mixed(plain(A),plain(B),plain(C))*half)

//(* Beginning of constructions. *)

function perspective(A1,S, p)
//(* Constructs a perspective image of a point A1 *)
//(* on the line p with respect to center S. *)
 return vector(vector(A1,S),p)

function diagonalpoint(A,B,C,D)
//(* Constructs a diagonal apex point of a complete quadrangle ABCD *)
//(* as the intersection of the opposite sides AB and CD. *)
 return perspective(A,B,vector(C,D))

function diagonalline(A,B,C,D)
//(* Construct a diagonal side of the quadrangle ABCD *)
//(* across diagonalpoint(A,B,C,D). *)
 return vector(diagonalpoint(B,C,A,D),diagonalpoint(A,C,B,D))

function middle(A,B,C,D)
//(* Returns the center of the segment AB in affine geometry with the absolute line CD. *)
 return perspective(A,B,diagonalline(A,B,C,D))

function harmonic(B,D,E,O)
//(* Applies the harmonic homology *)
//(* with center O and axis DE to point B. *)
 return middle(O,diagonalpoint(B,O,D,E),D,diagonalpoint(B,D,O,E))

function pappus(a,b,c,d,e)
//(* Construct Pappus' line of the points ae, be, ce, ad, bd, cd. *)
 return vector(diagonalline(c,b,d,e),diagonalline(a,b,d,e))

function steiner(B,D,E,O,X){
//(* Constructs the intersection of the curve B,D,E,EC,DO and line EX. *)
//(* Steiner's theorem says that x1 and x2 intersect *)
//(* at a point which belongs to the conic if and only if x1 is the image of x2 *)
//(* with respect to the projective mapping: EO,EB,ED -> DE,DB,DO *)
 var x1=vector(E,X)
 var x0=perspective(x1,vector(D,B),O)
 var x2=perspective(x0,vector(E,B),D)
 return vector(x1,x2)
}

(* Beginning of the part in charge of output. *)

procedure writereal(r: real);
begin
 write(r:8:4)
end;

procedure writereals(A: point);
var B: point;
begin
 B:=plain(A); writeln;
 with B^ do begin
  writereal(x); write(' xunit ');
  writereal(y); write(' yunit ')
 end;
 dispose(B)
end;

procedure moveto(A: point);
begin writereals(A); write('moveto') end;

procedure lineto(A: point);
begin writereals(A); write('lineto') end;

procedure showpoint(A: point; c:char);
(* Prints the label point. So far only first aid. *)
begin moveto(A); write(' (',c,') show') end;

procedure strokesegment(A,B: point);
(* Draws segment [AB]. *)
begin
 writeln; write('newpath');
 moveto(A); lineto(B); write(' stroke')
end;

procedure strokeline(p: line);
(* Draws the line AB. *)
var A,Lx,Rx,Ly,Ry: point; q: line;
begin
 q:=newpoint(one,zero,one); A:=vector(p,q); Lx:=plain(A); dispose(q); dispose(A);
 q:=newpoint(one,zero,-one); A:=vector(p,q); Rx:=plain(A); dispose(q); dispose(A);
 q:=newpoint(zero,one,one); A:=vector(p,q); Ly:=plain(A); dispose(q); dispose(A);
 q:=newpoint(zero,one,-one); A:=vector(p,q); Ry:=plain(A); dispose(q); dispose(A);
 if abs(Lx^.y)<=one then begin
  if abs(Ly^.x)<=one then strokesegment(Lx,Ly)
  else if abs(Rx^.y)<=one then strokesegment(Lx,Rx)
  else strokesegment(Lx,Ry)
 end else if abs(Ly^.x)<=one then begin
  if abs(Rx^.y)<=one then strokesegment(Ly,Rx)
  else if abs(Ry^.x)<=one then strokesegment(Ly,Ry)
 end else strokesegment(Rx,Ry)
end;

procedure strokefourpoint(A,B,C,D: point);
(* Draws quadrangle ABCD. *)
var p: line;
begin
 p:=vector(A,B); strokeline(p); dispose(p);
 p:=vector(A,C); strokeline(p); dispose(p);
 p:=vector(A,D); strokeline(p); dispose(p);
 p:=vector(B,C); strokeline(p); dispose(p);
 p:=vector(B,D); strokeline(p); dispose(p);
 p:=vector(C,D); strokeline(p); dispose(p)
end;

procedure writearc(B,D,E,O: point);
(* Draws a complement of the arc [DBE] recursively. *)
(* It is understood that D the is currentpoint. At the end that became E. *)
var P,F,S: point;
begin
 if area(D,O,E)<epsilon then lineto(E)
 else begin
  P:=middle(D,E,O,B); F:=harmonic(B,D,E,O);
  S:=diagonalpoint(D,O,F,P); writearc(B,D,F,S); dispose(S);
  S:=diagonalpoint(E,O,F,P); writearc(B,F,E,S); dispose(S);
  dispose(P); dispose(F)
 end
end;

procedure strokeconic(A,B,C,D,E: point);
(* Draws a curve ABCDE so that it draws one by one *)
(* complements of arcs [DBE], [EDB], [BED]. *)
var O: point;
begin
 writeln; write('newpath'); moveto(D);
 O:=pappus(A,B,C,D,E); write(' % begin complement[DBE]');
 writearc(B,D,E,O); dispose(O);
 O:=pappus(A,D,C,E,B); write(' % begin complement[EDB]');
 writearc(D,E,B,O); dispose(O);
 O:=pappus(A,E,C,B,D); write(' % begin complement[BED]');
 writearc(E,B,D,O); dispose(O);
 writeln(' stroke')
end;

procedure zoom(n: integer);
begin
 if n<1 then begin
  urx:=1; ury:=0
 end else begin
  zoom(n-1); urx:=urx+ury; ury:=urx-ury
 end
end;

procedure init;
begin
 randomize; (* Is it portable??? *)
 writeln('%!PS-Adobe EPSF-3.0'); zoom(13); epsilon:=5.0/urx/ury;
 writeln('%%BoundingBox: ',0,' ',0,' ',urx,' ',ury);
 writeln('% This is an automagicaly generated .eps file.');
 writeln('% Do not edit! Edit the source and recompile.');
 writeln('% See http://www.im.ns.ac.yu/~nenad/Conic/');
 writeln('/Times-Italic findfont 12 scalefont setfont');
 writeln('/xunit {',urx,' mul} def');
 write('/yunit {',ury,' mul} def')
end;

procedure writepicture;
var
 A,B,C,D,E: point; p: line;
begin
 A:=randompoint; showpoint(A,'A');
 B:=randompoint; showpoint(B,'B');
 C:=randompoint; showpoint(C,'C');
 D:=randompoint; showpoint(D,'D');
 E:=randompoint; showpoint(E,'E');
 strokefourpoint(A,B,C,D);
 strokeconic(A,B,C,D,E);
 dispose(A);
 dispose(B);
 dispose(C);
 dispose(D);
 dispose(E)
end;

begin
 init; writepicture
end.
