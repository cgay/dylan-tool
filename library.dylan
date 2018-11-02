Module: dylan-user

define library dylan-tool
  use collections,
    import: { table-extensions };
  use io,
    import: { format, format-out, print, streams };
  use json;
  use pacman;
  use regular-expressions;
  use strings;
  use system,
    import: { file-system, locators, operating-system };
  use uncommon-dylan,
    import: { uncommon-dylan, uncommon-utils };
end;

define module dylan-tool
  use file-system,
    prefix: "fs/";
  use format,
    import: { format, format-to-string };
  use format-out,
    import: { format-out, format-err };
  use json,
    import: { parse-json => json/parse };
  use locators,
    import: { <directory-locator>,
              <file-locator>,
              <locator>,
              locator-as-string,
              locator-directory,
              locator-name,
              merge-locators,
              relative-locator,
              subdirectory-locator };
  use operating-system,
    prefix: "os/";
  use pacman,
    prefix: "pm/";
  use print;
  use regular-expressions,
    import: { regex-parser };      // #regex:"..."
  use streams,
    import: { read-line, read-to-end, write };
  use strings,
    import: { lowercase,
              starts-with?,
              ends-with?,
              string-equal? => str=,
              string-equal-ic? => istr= };
  use table-extensions,
    import: { <case-insensitive-string-table> => <istr-map> };
  use uncommon-dylan;
  use uncommon-utils,
    import: { iff, slice };
end;
