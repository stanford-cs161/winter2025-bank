% -- LaTeX 3

\RequirePackage{expl3}
\RequirePackage{xparse}
\RequirePackage{l3keys2e}

% -- Class declaration

\ProvidesExplClass
	{bamboo}
	{2021/11/23}
	{1.0}
	{Cultivated class for svg-based documents by Nima Anari}

\keys_define:nn { bamboo } {
	fontsize .tl_set:N = \l_bamboo_fontsize_tl,
	hmargin .tl_set:N = \l_bamboo_hmargin,
	vmargin .tl_set:N = \l_bamboo_vmargin,
	unknown .code:n = {
		\PassOptionsToPackage{\CurrentOption}{pomegranate}
	}
}

\keys_set:nn { bamboo } {
	fontsize=11pt,
	hmargin=1in,
	vmargin=1in
}

\ProcessKeysOptions{bamboo}

% -- Base class

\use:x {
	\exp_not:N \LoadClass[
		\l_bamboo_fontsize_tl
	]{article}
}

% -- Packages

\RequirePackage[
	font=cmbright,
	geometry={hmargin=\l_bamboo_hmargin, vmargin=\l_bamboo_vmargin},
]{pomegranate}
\RequirePackage{xcoffins}

% -- Commands

\int_new:N \g_bamboo_question_int
\int_new:N \g_bamboo_choice_int

\int_gzero:N \g_bamboo_question_int

\cs_new:Nn \bamboo_q: {
	\int_use:N \g_bamboo_question_int
}
\cs_new:Nn \bamboo_new_q: {
	\int_gincr:N \g_bamboo_question_int
	\int_gzero:N \g_bamboo_choice_int
}

\cs_new:Nn \bamboo_ch: {
	\int_use:N \g_bamboo_choice_int
}
\cs_new:Nn \bamboo_new_ch: {
	\int_gincr:N \g_bamboo_choice_int
}



\NewCoffin \l_bamboo_stack_coffin
\NewCoffin \l_bamboo_current_coffin

\DeclareDocumentCommand{\BambooClear}{}{		\SetHorizontalCoffin \l_bamboo_stack_coffin {}
}
\DeclareDocumentCommand{\BambooAdd}{+m}{
	\SetHorizontalCoffin \l_bamboo_current_coffin {#1}
	\JoinCoffins \l_bamboo_stack_coffin[hc,vc] \l_bamboo_current_coffin[hc,vc]
}
\DeclareDocumentCommand{\BambooTypeset}{}{
	\TypesetCoffin \l_bamboo_stack_coffin
}

\DeclareDocumentCommand{\Group}{s t! d<> o o +m}{
	\str_set:Nn \l_tmpa_str {<g}
	\IfValueTF{#4}{
		\str_put_right:Nx \l_tmpa_str {~id="#4"}
	}{}
	\IfBooleanTF{#2}{
		\str_put_right:Nn \l_tmpa_str {~style="cursor:pointer"}
	}{}
	\IfBooleanTF{#1}{
		\str_put_right:Nn \l_tmpa_str {~visibility="hidden"}
	}{}
	\IfValueTF{#5}{
		\str_put_right:Nx \l_tmpa_str {~data-bamboo="#5"}
	}{}
	\IfValueTF{#3}{
		\str_put_right:Nx \l_tmpa_str {~data-bamboo-active="#3"}
	}{}
	\str_put_right:Nn \l_tmpa_str {>}
	\use:x{\exp_not:N \special{dvisvgm:raw~\l_tmpa_str}}
	#6
	\special{dvisvgm:raw~</g>}
}

\DeclareDocumentCommand{\Choice}{s +m}{
	\bamboo_new_ch:
	\Column<1>
	\BambooClear{}
	\BambooAdd{\Tikz{\draw[line~width=1, fill=White] circle(0.35em);}}
	\IfBooleanTF{#1}{
		\BambooAdd{\Group*[q\bamboo_q: Solution][\bamboo_ch: ]{\Tikz{\draw[line~width=1, fill=Gray] circle(0.35em);}}}
	}{}
	\IfBooleanTF{#1}{
		\Group![q\bamboo_q: Choice]{\BambooTypeset{}}
		\Column<29>
		\Group![q\bamboo_q: Text]{#2}
	}{
		\Group!<q\bamboo_q:>{\BambooTypeset{}}
		\Column<29>
		\Group!<q\bamboo_q:>{#2}
	}
}

\DeclareDocumentCommand{\Choices}{+m}{
	\bamboo_new_q:
	\Group[q\bamboo_q: ]{
		\begin{Columns}[Top]<30>
			#1
		\end{Columns}
		\Center{\Group*[q\bamboo_q: Alert]{\InlineBox[Green]{Correct}}}
	}
}

\DeclareDocumentCommand{\Freeform}{m}{
	\bamboo_new_q:
	\Group[q\bamboo_q: ]{
		\BambooClear{}
		\BambooAdd{\Group!<q\bamboo_q:>[q\bamboo_q: Box]{\Tikz{\draw[line~width=1, rounded~corners=0.2em, fill=White] rectangle (20em, 2em);}}}
		\BambooAdd{\Group*!<q\bamboo_q:>[q\bamboo_q: Solution][#1]{#1}}
		\Center{\BambooTypeset{}}
		\Center{\Group*[q\bamboo_q: Alert]{\InlineBox[Green]{Correct}}}
	}
}

\DeclareDocumentCommand{\Title}{m}{
	\Group[bambooTitle][#1]{{\Huge #1}}\hfill{\Group![bambooReset]{\InlineBox[Orange]{\small Reset~Progress\vphantom{Reveal~Solutions}}}~\Group![bambooReveal]{\InlineBox[Orange]{\small Reveal~Solutions\vphantom{Reset~Progress}}}}
	
	\par
	
	\rule{\textwidth}{1pt}
}

\dim_new:N \l_bamboo_height_dim
\NewCoffin \l_bamboo_coffin
\DeclareDocumentCommand{\Document}{+m}{
	\begin{document}
		\SetVerticalCoffin \l_bamboo_coffin {\textwidth} {#1}
		\dim_set:Nn \l_bamboo_height_dim {\CoffinTotalHeight\l_bamboo_coffin}
		\dim_add:Nn \l_bamboo_height_dim {\l_bamboo_vmargin}
		\dim_add:Nn \l_bamboo_height_dim {\l_bamboo_vmargin}
		\sys_if_output_pdf:TF {
			\sys_if_engine_luatex:TF {
				\global\pageheight=\dim_use:N \l_bamboo_height_dim
			} {
				\global\pdfpageheight=\dim_use:N \l_bamboo_height_dim
			}
			\global\paperheight=\dim_use:N \l_bamboo_height_dim
			\global\vsize=\dim_use:N \l_bamboo_height_dim
		} {
			\global\paperheight=\dim_use:N \l_bamboo_height_dim
			\global\vsize=\dim_use:N \l_bamboo_height_dim
		}
		\pagestyle{empty}
		\Group[bamboo]{
		\TypesetCoffin \l_bamboo_coffin
		}
		\special{dvisvgm:raw~<script~type="text/javascript"><![CDATA[}
\special{dvisvgm:raw~
(function(){
const~svg~=~document.documentElement;
const~bamboo~=~document.getElementById('bamboo');
const~qs~=~[];
for~(let~i=0;~i<bamboo.children.length;~i+=1)~{
~~~~if~(bamboo.children[i].id==="q"+(qs.length+1))~{
~~~~~~~~qs.push(bamboo.children[i]);
~~~~}
}
function~qNumber(q){
~~~~return~parseInt(q.id.split("q")[1]);
}

const~storageKey~=~document.getElementById("bambooTitle").getAttribute("data-bamboo");
const~resetButton~=~document.getElementById("bambooReset");
resetButton.setAttribute("accesskey",~"r");
const~revealButton~=~document.getElementById("bambooReveal");
revealButton.setAttribute("accesskey",~"s");

function~canonicalText(s){
~~~~const~t~=~s.replace(/~/g,~'');
~~~~return~t.toLowerCase();
}

function~setBoundary(elem,~box)~{
~~~~elem.setAttribute("x",~box.x);
~~~~elem.setAttribute("y",~box.y);
~~~~elem.setAttribute("width",~box.width);
~~~~elem.setAttribute("height",~box.height);
};
const~svgBox~=~svg.getBBox();
const~whiteRect~=~document.createElementNS("http://www.w3.org/2000/svg",~"rect");
whiteRect.setAttribute("fill",~"white");
function~clipTo(q)~{
~~~~let~y;
~~~~if~(q)~{
~~~~~~~~const~qBox~=~q.getBBox();
~~~~~~~~y=Math.min(qBox.y+qBox.height,~svgBox.y+svgBox.height);
~~~~}~else~{
~~~~~~~~y~=~svgBox.y+svgBox.height;
~~~~}
~~~~setBoundary(whiteRect,~{
~~~~~~~~x:~svgBox.x-1,
~~~~~~~~y:~y,
~~~~~~~~width:~svgBox.width+2,
~~~~~~~~height:~svgBox.y+svgBox.height-y
~~~~});
}
clipTo(null);
svg.appendChild(whiteRect);

function~setSolve(q,~state)~{
~~~~const~id~=~q.id;
~~~~document.getElementById(id+"Solution").style.visibility=~state~?~"visible"~:~"hidden";
~~~~document.getElementById(id+"Alert").style.visibility~=~state~?~"visible"~:~"hidden";
}

const~inputObject~=~document.createElementNS("http://www.w3.org/2000/svg",~"foreignObject");
const~inputElement~=~document.createElementNS("http://www.w3.org/1999/xhtml",~"input");
inputElement.style.width="100\%";
inputElement.style.height="100\%";
inputElement.style.textAlign="center";
svg.appendChild(inputObject);
inputObject.appendChild(inputElement);
function~setInput(box){
~~~~if~(box)~{
~~~~~~~~setBoundary(inputObject,~box);
~~~~~~~~inputObject.style.visibility~=~"visible";
~~~~~~~~inputElement.value="";
~~~~~~~~inputElement.focus();
~~~~}
~~~~else~{
~~~~~~~~inputObject.style.visibility~=~"hidden";
~~~~}
}
setInput(null);

const~active~=~{
~~~~question:~null,
~~~~solution:~null,
~~~~type:~null
};

function~setActiveQuestion(q)~{
~~~~if~(q~&&~active.question===q)
~~~~~~~~return;
~~~~setInput(null);
~~~~for~(let~qi=0;~qi<qs.length;~qi++)~{
~~~~~~~~setSolve(qs[qi],~(q~?~qNumber(qs[qi])<qNumber(q)~:~true));
~~~~}
~~~~active.question~=~q;
~~~~active.solution~=~null;
~~~~active.type~=~null;
~~~~const~qsolution~=~q?~document.getElementById(q.id+"Solution")~:~null;
~~~~if~(qsolution){
~~~~~~~~active.solution~=~qsolution.getAttribute("data-bamboo");
~~~~}
~~~~if~(q~&&~document.getElementById(q.id+"Choice"))
~~~~~~~~active.type~=~"choice";
~~~~if~(q~&&~document.getElementById(q.id+"Box"))
~~~~~~~~active.type~=~"freeform";
~~~~clipTo(q);
~~~~const~qbox~=~q~?~document.getElementById(q.id+"Box")~:~null;
~~~~if~(qbox){
~~~~~~~~setInput(qbox.getBBox());
~~~~}
~~~~window.localStorage.setItem(storageKey,~q~?~q.id~:~"all");
}

function~solveActiveQuestion(){
~~~~let~qNext~=~null;
~~~~for~(qi=0;qi+1<qs.length;qi++)~{
~~~~~~~~if~(active.question===qs[qi])
~~~~~~~~~~~~qNext~=~qs[qi+1];
~~~~}
~~~~setActiveQuestion(qNext);
}

resetButton.addEventListener("click",~function(){
~~~~setActiveQuestion(qs[0]);
});

revealButton.addEventListener("click",~function(){
~~~~setActiveQuestion(null);
});

for~(let~qi=0;~qi<qs.length;~qi++){
~~~~const~q~=~qs[qi];
~~~~qchoice~=~document.getElementById(q.id+"Choice");
~~~~qtext~=~document.getElementById(q.id+"Text");
~~~~if~(qchoice)~{
~~~~~~~~qchoice.addEventListener("click",~function(){
~~~~~~~~~~~~setActiveQuestion(q);
~~~~~~~~~~~~solveActiveQuestion();
~~~~~~~~});
~~~~}
~~~~if~(qtext)~{
~~~~~~~~qtext.addEventListener("click",~function(){
~~~~~~~~~~~~setActiveQuestion(q);
~~~~~~~~~~~~solveActiveQuestion();
~~~~~~~~});
~~~~}
~~~~const~activators~=~document.querySelectorAll("[data-bamboo-active='"+q.id+"']");
~~~~for~(let~ai=0;ai<activators.length;ai++)~{
~~~~~~~~activators[ai].addEventListener("click",~function(){
~~~~~~~~~~~~setActiveQuestion(q);
~~~~~~~~});
~~~~}
}

document.addEventListener("keypress",~function(event){
~~~~if~(active.type==="choice"~&&~active.solution){
~~~~~~~~if~(event.key===active.solution)
~~~~~~~~~~~~solveActiveQuestion();
~~~~~~~~if~(event.key>='1'~&&~event.key<='9')
~~~~~~~~~~~~event.preventDefault();
~~~~}
});

inputElement.addEventListener("input",~function(){
~~~~if~(active.type==="freeform"~&&~active.solution){
~~~~~~~~if~(canonicalText(inputElement.value)===canonicalText(active.solution)){
~~~~~~~~~~~~solveActiveQuestion();
~~~~~~~~}
~~~~}
});

let~stored~=~window.localStorage.getItem(storageKey);
if~(!stored){
~~~~stored~=~qs[0].id;
}
if~(stored==="all"){
~~~~setActiveQuestion(null);
}
for~(let~qi=0;qi<qs.length;qi++){
~~~~if~(qs[qi].id===stored)
~~~~~~~~setActiveQuestion(qs[qi]);
}
})();
}
		\special{dvisvgm:raw~]]></script>}
	\end{document}
}