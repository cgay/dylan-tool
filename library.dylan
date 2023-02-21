Module: dylan-user

define library dylan-tool
  use collections,
    import: { table-extensions };
  use command-line-parser;
  use dylan,
    import: { dylan-extensions };
  use io,
    import: { format, format-out, print, standard-io, streams };
  use json;
  use regular-expressions;
  use file-source-records;
  use strings;
  use system,
    import: { date, file-system, locators, operating-system };
  use uncommon-dylan,
    import: { uncommon-dylan, uncommon-utils };

  export
    dylan-tool,
    pacman,
    %pacman,
    shared,
    workspaces,
    %workspaces;
end library;

// Definitions used by all the other modules.
define module shared
  use format-out;
  use operating-system, prefix: "os/";
  use streams;
  use strings;
  use uncommon-dylan;
  export
    *debug?*,
    *verbose?*,
    debug,
    note,
    verbose,
    trace,
    warn,
    locate-dylan-compiler;
end module;

define module pacman
  export
    <catalog-error>,
    catalog,
    dylan-directory,            // $DYLAN or $HOME/dylan or /opt/dylan

    <catalog>,
    catalog-directory,
    find-package,
    find-package-release,
    validate-catalog,
    write-package-file,

    <package>,
    package-category,
    package-contact,
    package-description,
    package-keywords,
    package-locator,
    package-name,
    package-releases,

    <package-error>,
    download,
    install,
    install-deps,
    installed-versions,
    installed?,
    load-all-catalog-packages,
    load-catalog-package,
    load-dylan-package-file,
    package-directory,
    release-directory,
    source-directory,

    <release>,
    publish-release,
    release-dependencies,
    release-dev-dependencies,
    release-license,
    release-to-string,
    release-url,
    release-version,

    <dep-vector>,
    <dep>,
    dep-to-string, string-to-dep,
    dep-version,
    resolve-deps,
    resolve-release-deps,

    $latest,
    <branch-version>,
    <semantic-version>,
    <version>,
    version-branch,
    version-major,
    version-minor,
    version-patch;
end module;

define module %pacman
  use date,
    import: { current-date, <duration> };
  use file-system, prefix: "fs/";
  use format;
  use format-out;
  use json;
  use locators;
  use operating-system, prefix: "os/";
  use print;
  use regular-expressions;
  use shared;
  use streams;
  use strings;
  use uncommon-dylan,
    exclude: { format-out, format-to-string };
  // Do we need this?
  use uncommon-utils,
    import: { elt, iff, <singleton-object>, value-sequence };

  use pacman, export: all;

  // For the test suite.
  export
    $dylan-env-var,
    <dep-conflict>,
    <dep-error>,
    <latest>,
    add-release,
    cache-package,
    cached-package,
    catalog-package-cache,
    find-release,
    max-release,
    string-parser,                 // #string:...
    string-to-version, version-to-string;
end module;

define module workspaces
  create
    $dylan-package-file-name,
    $workspace-file-name,
    <workspace-error>,
    <workspace>,
    active-package-directory,
    active-package-file,
    active-package?,
    configured-test-libraries,
    find-active-package-library-names,
    find-dylan-package-file,
    find-library-names,
    find-workspace-directory,
    find-workspace-file,
    load-workspace,
    new,
    source-file-map,
    update,
    workspace-active-packages,
    workspace-default-library-name,
    workspace-directory,
    workspace-registry-directory,
    workspace-release;
end module;

define module %workspaces
  use dylan-extensions,
    import: { address-of };
  use file-system, prefix: "fs/";
  use format;
  use format-out;
  use json;
  use locators;
  use operating-system, prefix: "os/";
  use pacman, prefix: "pm/";
  use print;
  use regular-expressions;
  use shared;
  use file-source-records, prefix: "sr/";
  use standard-io;
  use streams;
  use strings;
  use uncommon-dylan,
    exclude: { format-to-string };
  use uncommon-utils,
    import: { err, iff, inc!, slice };
  use workspaces;

  // Exports for the test suite.
  export
    $lid-key,
    lid-data,
    lid-value,
    lid-values,
    parse-lid-file,
    <registry>;
end module;

define module dylan-tool
  use command-line-parser;
  use file-system, prefix: "fs/";
  use format;
  use format-out;
  use json;
  use locators;
  use operating-system, prefix: "os/";
  use pacman, prefix: "pm/";
  use regular-expressions;
  use shared;
  use standard-io;
  use streams;
  use strings;
  use uncommon-dylan,
    exclude: { format-to-string };
  use uncommon-utils,
    import: { err, iff, inc!, slice };
  use workspaces, prefix: "ws/";

  export
    dylan-tool-command-line;
end module;
