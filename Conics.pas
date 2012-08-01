program conics;

const
 zero=0.0;
 half=0.5;
 one=1.0;
 biginteger=1024;
 bigreal=1024.0;
type
 tpoint=record x,y,z: real end; point=^tpoint;
 line=point; (* Duality! *)
 (* Polar (line) is presented by its pole (point). See http://en.wikipedia.org/wiki/Pole_and_polar *)
var
 urx,ury: integer; (* The coordinates of the upper-right corner of the image. *)
 epsilon: real;

function newpoint(x0,y0,z0: real): point;
(* The only procedure that contains new(A: point). *)
var A: point;
begin
 new(A); with A^ do begin x:=x0; y:=y0; z:=z0 end;
 newpoint:=A
end;

function plain(A: point): point;
(* Projects point on the drawing plane z=1. *)
var B: point;
begin
 with A^ do B:=newpoint(x/z,y/z,one);
 plain:=B
end;

function norm(A: point): real;
(* The distance from (0,0,0). Any type of it. *)
var r: real;
begin
 with A^ do r:=abs(x)+abs(y)+abs(z);
 norm:=r
end;

function normed(A: point): point;
(* Projects point on the unit sphere (or cube or octaedar). *)
var B: point; r: real;
begin
 r:=norm(A);
 with A^ do begin
  if z<zero then r:=-r; B:=newpoint(x/r,y/r,z/r)
 end;
 normed:=B
end;

function randominteger: integer;
(* A random integer in the interval [0,1024). *)
begin
 randominteger:=random(biginteger)
end;

function randomreal: real;
 (* A random number in the interval (-1,1). Densest distribution around zero. *)
 (* A random number in the interval (0,1). Densest distribution of about 1/2. *)
begin
 (* randomreal:=(randominteger-randominteger)/bigreal *)
 randomreal:=(randominteger-randominteger)/bigreal/2.0+0.5
end;

function randompoint: point;
(* Random point in the plane. *)
var A,B: point;
begin
 A:=newpoint(randomreal,randomreal,one);
 B:=normed(A); dispose(A);
 randompoint:=B
end;

function scalar(A: point; p: line): real;
(* Dot product. Should be changed to distance(...). *)
begin
 scalar:=A^.x*p^.x + A^.y*p^.y + A^.z*p^.z
end;

function element(A: point; p: line): boolean;
(* Currently not used. *)
begin
 element:=scalar(A,p)=zero
end;

function vector(p1,p2: line): point;
(* Cross product. Base for any construction. *)
(* Returns the intersection point of two straight lines, and dual, line through the two points. *)
var A,B: point;
begin
 A:=newpoint(
  p1^.y * p2^.z - p1^.z * p2^.y,
  p1^.z * p2^.x - p1^.x * p2^.z,
  p1^.x * p2^.y - p1^.y * p2^.x);
 B:=normed(A);
 dispose(A);
 vector:=B
end;

function mixed(A,B,C: point): real;
(* Mixed product. *)
var l: line; r: real;
begin
 l:=vector(B,C); r:=scalar(A,l); dispose(l);
 mixed:=r
end;

function area(A,B,C: point): real;
(* Area of triangle ABC. *)
var A0,B0,C0: point; r: real;
begin
 A0:=plain(A); B0:=plain(B); C0:=plain(C);
 r:=abs(mixed(A0,B0,C0)*half);
 dispose(A0); dispose(B0); dispose(C0);
 area:=r
end;

(* Beginning of constructions. *)

function perspective(A1,S: point; p: line): point;
(* Constructs a perspective image of a point A1 *)
(* on the line p with respect to center S. *)
var q: line; A2: point;
begin
 q:=vector(A1,S); A2:=vector(p,q);
 dispose(q); perspective:=A2
end;

function diagonalpoint(A,B,C,D: point): point;
(* Constructs a diagonal apex point of a complete quadrangle ABCD *)
(* as the intersection of the opposite sides AB and CD. *)
var p: line; X: point;
begin
 p:=vector(C,D); X:=perspective(A,B,p);
 dispose(p); diagonalpoint:=X
end;

function diagonalline(A,B,C,D: point): line;
(* Construct a diagonal side of the quadrangle ABCD *)
(* across diagonalpoint(A,B,C,D). *)
var Y,Z: point; x: line;
begin
 Y:=diagonalpoint(B,C,A,D); Z:=diagonalpoint(A,C,B,D);
 x:=vector(Y,Z); dispose(Y); dispose(Z);
 diagonalline:=x
end;

function middle(A,B,C,D: point): point;
(* Returns the center of the segment AB in affine geometry with the absolute line CD. *)
var S: point; x: line;
begin
 x:=diagonalline(A,B,C,D); S:=perspective(A,B,x); dispose(x);
 middle:=S
end;

function harmonic(B,D,E,O: point): point;
(* Applies the harmonic homology *)
(* with center O and axis DE to point B. *)
var F,X,Z: point;
begin
 X:=diagonalpoint(B,D,O,E); Z:=diagonalpoint(B,O,D,E);
 F:=middle(O,Z,D,X); dispose(X); dispose(Z);
 harmonic:=F
end;

function pappus(a,b,c,d,e: line): line;
(* Construct Pappus' line of the points ae, be, be, ad, bd, cd. *)
var P,Q: point; o: line;
begin
 P:=diagonalline(c,b,d,e); Q:=diagonalline(a,b,d,e);
 o:=vector(P,Q); dispose(P); dispose(Q);
 pappus:=o
end;

function steiner(B,D,E,O,X: point): point;
(* Constructs the intersection of the curve B,D,E,EC,DO and line EX. *)
(* Steiner's theorem says that x1 and x2 intersect *)
(* at a point which belongs to the conic if and only if x1 is the image x2 *)
(* with respect to the projective mapping: EO,b1,ED -> DE,b2,DO *)
var b1,b2,x0,x1,x2: line; F: point;
begin
 x1:=vector(E,X); b1:=vector(E,B); b2:=vector(D,B);
 x0:=perspective(x1,b2,O); x2:=perspective(x0,b1,D);
 F:=vector(x1,x2); dispose(b1); dispose(b2);
 dispose(x0); dispose(x1); dispose(x2);
 steiner:=F
end;

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
