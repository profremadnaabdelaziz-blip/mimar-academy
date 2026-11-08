/ src/data/memaarConfig.ts
import { memaarData } from "./memaarData";
import type { Gate, Pillar } from "./memaarData";
import type { ContentType } from "./memaarContent";

export type LevelId = number;

export function getPortal(slug: string | undefined): Pillar | undefined {
  if (!slug) return undefined;
  return memaarData.find((portal) => portal.slug === slug);
}

export function getHub(
  portal: ReturnType<typeof getPortal>,
  hubId: string | number | undefined
): Gate | undefined {
  if (!portal || hubId === undefined || hubId === null) return undefined;

  const id = Number(hubId);
  if (!Number.isFinite(id)) return undefined;

  return portal.gates.find((gate) => gate.id === id);
}

export function hubUrl(
  portalSlug: string,
  levelId: LevelId,
  hubId: number | string,
  type: ContentType
): string {
  return `/academy/${encodeURIComponent(
    portalSlug
  )}/level-${encodeURIComponent(String(levelId))}/hub-${encodeURIComponent(
    String(hubId)
  )}/${encodeURIComponent(type)}`;
}

export function getPortalByGateId(
  gateId: number | string
): Pillar | undefined {
  const id = Number(gateId);
  if (!Number.isFinite(id)) return undefined;

  return memaarData.find((portal) =>
    portal.gates.some((gate) => gate.id === id)
  );
}

export function getAllPortals(): Pillar[] {
  return memaarData;
}

export function getPortalStats() {
  return {
    portals: memaarData.length,
    gates: memaarData.reduce((sum, portal) => sum + portal.gates.length, 0),
  };
}
