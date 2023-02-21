Module: dylan-tool
Synopsis: Definition of the command-line as a whole


// Parent of "new library", "new workspace", et al.
define class <new-subcommand> (<subcommand>)
  keyword name = "new";
  keyword help = "";
end;

define function dylan-tool-command-line
    () => (p :: <command-line-parser>)
  make(<command-line-parser>,
       help:
         format-to-string("Dylan dev swiss army knife - %s\n"
                            "https://docs.opendylan.org/packages/dylan-tool/documentation/source/",
                          $dylan-tool-version),
       options:
         list(make(<flag-option>,
                   name: "verbose",
                   help: "Generate more verbose output."),
              make(<flag-option>,
                   name: "debug",
                   help: "Enter the debugger (or print a backtrace) on error.")),
       subcommands:
         list($build-subcommand,
              $install-subcommand,
              $list-subcommand,
              make(<new-subcommand>,
                   subcommands: list($new-application-subcommand,
                                     $new-library-subcommand,
                                     $new-workspace-subcommand)),
              $publish-subcommand,
              $status-subcommand,
              $test-subcommand,
              $update-subcommand,
              $version-subcommand))
end function;
