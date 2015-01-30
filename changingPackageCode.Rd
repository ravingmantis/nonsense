  \subsection{Running package unit tests as you develop the code}{
    By far the simplest and safest way to do this is to make your changes,
    build the package and run 'R CMD check' against the built package.

    Since this can often be too much of an overhead or because you prefer the comfort of an
    interactive \code{R} session we offer two possible alternative strategies. Both these
    strategies come with the warning: \emph{here be dragons}.

    \subsection{Editing functions in place}{
      In a new \code{R} session load the current version of your package in the usual way, then
      change your working directory to the root of your package source something like this
      \preformatted{
        setwd("path/to/mypackage")
      }
      and use the following procedure
      \itemize{
        \item Update your unit tests to test the forthcoming changes.
        \item Edit the function being tested \sQuote{in place}. The following command will open the
              default system editor; when you save and close the editor the local \code{R} session
              copy of the function has been modified. 
              \preformatted{
                fix('biggest')
              }
              If the function is not exported into the environment search path you can explicitly
              reference the environment.
              \preformatted{
                fixInNamespace('biggest', pos='namespace:mypackage')
              }
        \item Use the \code{source()} command to run your unit tests against the function using the
              \code{chdir} option to make sure that your unit tests run in the same directory that
              \code{R CMD check} will run them.
              \preformatted{
                source("tests/test_biggest.R", chdir=TRUE)
              }
        \item Once you are happy with the changes you can save the modified function from your \code{R}
              session using the \code{sink()} command
              \preformatted{
                sink(file='R/biggest.R.new.tmp')
                biggest
                sink()
              }
              The saved copy will only include the \code{function(...)\{...\}} so you will need to
              manually merge this back into your source file.
      }
      Remember that if you save your \code{R} session your function edits will also be saved and that
      if you exit your session without saving your edits will be lost.
    }
  }
