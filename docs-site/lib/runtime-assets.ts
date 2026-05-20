import * as fs from "fs";
import * as path from "path";

export interface RuntimeAssets {
  js: string;
  css: string;
  vanillaJs?: string;
}

export function getRuntimeAssets(): RuntimeAssets {
  const runtimeDir = path.join(process.cwd(), "public/runtime");
  
  try {
    if (fs.existsSync(runtimeDir)) {
      const items = fs.readdirSync(runtimeDir).sort().reverse();
      const shinyblocksFolder = items.find(
        (item) => item.startsWith("shinyblocks-") && fs.statSync(path.join(runtimeDir, item)).isDirectory()
      );

      if (shinyblocksFolder) {
        return {
          js: `/shinyblocks/runtime/${shinyblocksFolder}/shinyblocks-runtime.js`,
          css: `/shinyblocks/runtime/${shinyblocksFolder}/shinyblocks-runtime.css`,
          vanillaJs: `/shinyblocks/runtime/${shinyblocksFolder}/shinyblocks.js`,
        };
      }
    }
  } catch (error) {
    console.error("Failed to read runtime assets directory:", error);
  }

  // Fallbacks if not found
  return {
    js: "",
    css: "",
  };
}
