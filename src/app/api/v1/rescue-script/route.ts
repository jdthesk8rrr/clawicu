import { NextRequest, NextResponse } from "next/server";
import { readFileSync } from "fs";
import { join } from "path";

function getRescueScript(os: string, version: string): string {
  const templatePath = join(process.cwd(), "src/data/rescue-template.sh");
  let script = readFileSync(templatePath, "utf-8");
  script = script.replace(/\{\{OS\}\}/g, os);
  script = script.replace(/\{\{VERSION\}\}/g, version);
  script = script.replace(/\{\{TIMESTAMP\}\}/g, new Date().toISOString());
  return script;
}

export async function GET(request: NextRequest) {
  const searchParams = request.nextUrl.searchParams;
  const os = searchParams.get("os") || "linux";
  const version = searchParams.get("version") || "0.1.0";

  const scriptContent = getRescueScript(os, version);

  return new NextResponse(scriptContent, {
    headers: {
      "Content-Type": "text/plain",
      "Content-Disposition": "attachment; filename=rescue.sh",
    },
  });
}
