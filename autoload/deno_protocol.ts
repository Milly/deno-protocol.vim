try {
  const denoUrl = decodeURIComponent(Deno.args[0]);
  const fixImport = Deno.args[1] === "--fix-import";

  const url = denoUrl.replace(/^deno:\/(https?)\//, "$1://");
  if (denoUrl === url) {
    throw `Invalid url`;
  }

  const res = await fetch(url);
  if (!res.ok) {
    throw `${res.statusText}`;
  }

  let source = await res.text();

  if (fixImport) {
    const baseUrl = url.replace(/\/[^\/]*$/, "");
    source = source.replaceAll(
      /((?:^|;)\s*(?:import|export)\s[^;]*\sfrom\s+["'])((?:\.\.?\/)+)/mg,
      (...[, prefix, relpath]: string[]) => {
        const newUrl = relpath.slice(0, -1).split("/")
          .filter((s) => s === "..")
          .reduce((url) => url.replace(/\/[^\/]*$/, ""), baseUrl);
        return `${prefix}${newUrl}/`;
      },
    );
  }

  await Deno.stdout.write(new TextEncoder().encode(source));
} catch (e) {
  console.error(e);
  Deno.exit(1);
}
