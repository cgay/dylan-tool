Module: dylan-tool
Synopsis: dylan test subcommand


define class <test-subcommand> (<subcommand>)
  keyword name = "test";
  keyword help = "Build and run test suites.";
end class;

// dylan test [--clean] [--all | lib1 lib2 ...]
// Eventually need to add more dylan-compiler options to this.
define constant $test-subcommand
  = make(<test-subcommand>,
         options:
           list(make(<flag-option>,
                     names: #("all", "a"),
                     help: "Build and run all test libraries in the workspace."),
                make(<flag-option>,
                     names: #("clean", "c"),
                     help: "Do a clean build."),
                make(<positional-option>,
                     names: #("libraries"),
                     help: "Test libraries to build and run.",
                     repeated?: #t,
                     required?: #f)));

define method execute-subcommand
    (parser :: <command-line-parser>, subcmd :: <test-subcommand>)
 => (status :: false-or(<int>))
  let workspace = ws/load-workspace();
  let workspace-dir = ws/workspace-directory(workspace);
  let libraries = get-option-value(subcmd, "libraries") | #[];
  let all? = get-option-value(subcmd, "all");
  if (all?)
    if (~empty?(libraries))
      warn("Ignoring --all option; using the specified libraries instead.");
    else
      local method test-library? (name :: <string>)
              // Being intentionally restrictive about test library names...
              any?(curry(ends-with?, name),
                   #["-test-suite", "-test-suite-app"])
            end;
      let libs = ws/find-active-package-library-names(workspace);
      debug("active package libs: %=", libs);
      libraries := choose(test-library?, libs);
      if (empty?(libraries))
        error("No tests found in workspace.");
      end;
    end;
  end;
  if (empty?(libraries))
    libraries
      := ws/configured-test-libraries(workspace)
         | error("No tests found in workspace and no default tests configured.");
  end;

  // Build all test libraries.
  let dylan-compiler = locate-dylan-compiler();
  for (name in libraries)
    let command = remove(vector(dylan-compiler,
                                "-build",
                                get-option-value(subcmd, "clean") & "-clean",
                                name),
                         #f);
    debug("Running command %=", command);
    let env = make-compilation-environment(workspace);
    let exit-status
      = os/run-application(command,
                           environment: env,
                           under-shell?: #f,
                           working-directory: workspace-dir);
    if (exit-status ~== 0)
      error("Build of %= failed with exit status %=.", name, exit-status);
    end;
  end for;

  // Run the tests.
  let testworks-run-built? = #f;
  let testworks-run-file = exe-filename(workspace-dir, "testworks-run");
  for (name in libraries)
    let app-file = exe-filename(workspace-dir, name);
    let lib-file = dll-filename(workspace-dir, name);
    if (fs/file-exists?(app-file))
      run-test-app(app-file);
    elseif (fs/file-exists?(lib-file))
      note("Building testworks-run in order to run shared library test"
             " suite %s.", name);
      let exit-status
        = os/run-application(vector(dylan-compiler, "-build", "testwork-run"),
                             under-shell?: #f,
                             working-directory: workspace-dir);
      if (exit-status ~== 0)
        error("Build of testworks-run failed with exit status %=.", exit-status);
      end;
      let exit-status
        = os/run-application(vector(testworks-run-file, "--load", lib-file),
                             under-shell?: #f,
                             working-directory: workspace-dir);
      if (exit-status ~== 0)
        // TODO: for now we just die.
        error("Tests for %s failed.", name);
      end;
    else
      error("No test binary found for library %s.", name);
    end;
  end for;
end method;

define function exe-filename
    (workspace-dir :: <directory-locator>, name :: <string>)
 => (file :: <file-locator>)
  // TODO: We assume not "sbin" for now...
  file-locator(workspace-dir, "_build", "bin",
               iff(os/$os-name == #"win32",
                   concat(name, ".exe"),
                   name))
end function;

define function dll-filename
    (workspace-dir :: <directory-locator>, name :: <string>)
 => (file :: <file-locator>)
  file-locator(workspace-dir, "_build", "lib",
               iff(os/$os-name == #"win32",
                   concat(name, ".dll"),
                   concat("lib", name, ".so")))
end function;

define function run-test-app
    (file :: <file-locator>)
  debug("Running test app %s", file);
  os/run-application(vector(as(<string>, file)))
end function;
