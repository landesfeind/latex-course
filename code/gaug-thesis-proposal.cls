%\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{gaug-thesis-proposal}[2012/06/01 v0.1 
	Class for thesis proposals at the University of Goettingen]

% Specify command to contain the type of the thesis
\newcommand{\@thesistype}{Bachelor}

% Passes options to the underlying article class
\DeclareOption*{\PassOptionsToClass{\CurrentOption}{article}}
\DeclareOption{bachelor}{\renewcommand{\@thesistype}{Bachelor}}
\DeclareOption{master}{\renewcommand{\@thesistype}{Master}}
\ProcessOptions

% Use the article class as a base
\LoadClass[titlepage,a4paper]{article}

%
% Lets start creating own commands
%

% 1.) Command to define the working group
\newcommand{\@workinggroup}{Unkown}
\newcommand{\workinggroup}[1]{\renewcommand{\@workinggroup}{#1}}

% 2.) Command to define your supervisor
\newcommand{\@supervisor}{Unkown}
\newcommand{\supervisor}[1]{\renewcommand{\@supervisor}{#1}}

% 3.) Maybe define another command



\renewcommand{\maketitle}{
\begin{titlepage}
	\@author
	\@title
	\@date
	\@supervisor
	
	% Ideen fuer das Layout:
	% Schriftgoessen:
	%\small, \huge, \large
	%\vfill, \hfill, \vspace, \hspace*{Xcm}
	%\rule, \hrule
	%% Bilder
\end{titlepage}
}














\newcommand{\maketitlepage}{
	\null
	\vfill

	\begin{center}
		{\huge \@thesistype\ thesis proposal}
	
		\rule{\linewidth}{3pt}

		\vspace{2cm}

		{\Large\textbf \@title}\\[1cm]
		by\\
		{\large \@author}\\[2cm]
		supervision by\\
		{\large \@supervisor}\\
		at the\\
		\@workinggroup

		\vspace{2cm}

		\rule{\linewidth}{3pt}

		\@date

	\end{center}

	\vfill
}

\renewcommand{\maketitle}{
	\begin{titlepage}%
	  \maketitlepage%
	\end{titlepage}
	\global\let\thanks\relax
	\global\let\maketitle\relax
	\global\let\@thanks\@empty
	\global\let\@author\@empty
	\global\let\@date\@empty
	\global\let\@title\@empty
	\global\let\title\relax
	\global\let\author\relax
	\global\let\date\relax
	\global\let\and\relax
}
