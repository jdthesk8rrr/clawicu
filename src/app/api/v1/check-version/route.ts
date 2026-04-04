import { NextRequest, NextResponse } from "next/server";

const MIN_VERSION = "1.0.0";
const MAX_VERSION = "99.99.99"; // Future-proof

function compareVersions(a: string, b: string): number {
  const partsA = a.split(".").map(Number);
  const partsB = b.split(".").map(Number);
  
  for (let i = 0; i < Math.max(partsA.length, partsB.length); i++) {
    const partA = partsA[i] || 0;
    const partB = partsB[i] || 0;
    if (partA > partB) return 1;
    if (partA < partB) return -1;
  }
  return 0;
}

export async function GET(request: NextRequest) {
  const searchParams = request.nextUrl.searchParams;
  const version = searchParams.get("version");
  
  if (!version) {
    return NextResponse.json(
      { error: "version parameter required" },
      { status: 400 }
    );
  }
  
  const minOk = compareVersions(version, MIN_VERSION) >= 0;
  const maxOk = compareVersions(version, MAX_VERSION) <= 0;
  
  if (!minOk) {
    return NextResponse.json({
      version,
      status: "unsupported",
      message: `OpenClaw ${version} is too old. Minimum supported: ${MIN_VERSION}`,
      canRepair: true,
    });
  }
  
  if (!maxOk) {
    return NextResponse.json({
      version,
      status: "unknown",
      message: `OpenClaw ${version} is newer than tested. Proceed with caution.`,
      canRepair: true,
    });
  }
  
  return NextResponse.json({
    version,
    status: "supported",
    message: `OpenClaw ${version} is supported`,
    canRepair: false,
  });
}