import { clsx, type ClassValue } from "clsx";
import { twMerge } from "tailwind-merge";

// Standard shadcn `cn()` helper — merges class names and dedupes Tailwind
// utilities. Use this anywhere you build conditional className strings.
export function cn(...inputs: ClassValue[]): string {
  return twMerge(clsx(inputs));
}
