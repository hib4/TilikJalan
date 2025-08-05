"use client";

import { useEffect, useRef, useState } from "react";
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { ZoomIn, ZoomOut, RotateCcw, MapPin } from "lucide-react";
import type { Map as LeafletMap, LeafletEvent } from "leaflet";

// Data contoh segmen jalan untuk Jakarta
const roadSegments = [
  {
    id: 1,
    name: "Jl. Sudirman",
    coordinates: [
      [-6.2088, 106.8456],
      [-6.2188, 106.8356],
      [-6.2288, 106.8256],
    ],
    priority: "high",
    priorityScore: 9.5,
    status: "Baru",
    lastInspection: "2024-01-15",
    damageType: "Lubang Jalan",
    length: "2,3 km",
  },
  {
    id: 2,
    name: "Jl. Thamrin",
    coordinates: [
      [-6.1944, 106.8229],
      [-6.2044, 106.8329],
      [-6.2144, 106.8429],
    ],
    priority: "high",
    priorityScore: 9.2,
    status: "Sedang Ditinjau",
    lastInspection: "2024-01-14",
    damageType: "Keausan Permukaan",
    length: "1,8 km",
  },
  {
    id: 3,
    name: "Jl. Gatot Subroto",
    coordinates: [
      [-6.2297, 106.8253],
      [-6.2397, 106.8353],
      [-6.2497, 106.8453],
    ],
    priority: "medium",
    priorityScore: 8.8,
    status: "Dijadwalkan",
    lastInspection: "2024-01-12",
    damageType: "Retakan",
    length: "3,1 km",
  },
  {
    id: 4,
    name: "Jl. Rasuna Said",
    coordinates: [
      [-6.22, 106.84],
      [-6.23, 106.85],
    ],
    priority: "medium",
    priorityScore: 8.5,
    status: "Sedang Dikerjakan",
    lastInspection: "2024-01-10",
    damageType: "Kerusakan Pinggir Jalan",
    length: "2,7 km",
  },
  {
    id: 5,
    name: "Jl. Kuningan",
    coordinates: [
      [-6.235, 106.83],
      [-6.245, 106.84],
      [-6.255, 106.85],
    ],
    priority: "low",
    priorityScore: 6.1,
    status: "Selesai",
    lastInspection: "2024-01-08",
    damageType: "Keausan Ringan",
    length: "1,5 km",
  },
  {
    id: 6,
    name: "Jl. Senayan",
    coordinates: [
      [-6.225, 106.815],
      [-6.235, 106.825],
      [-6.245, 106.835],
    ],
    priority: "low",
    priorityScore: 5.8,
    status: "Baik",
    lastInspection: "2024-01-05",
    damageType: "Tidak Ada",
    length: "2,0 km",
  },
];

const priorityColors = {
  high: "#FF3B30",
  medium: "#FF9500",
  low: "#34C759",
};

const priorityLabels = {
  high: "Prioritas Tinggi",
  medium: "Prioritas Menengah",
  low: "Prioritas Rendah",
};

export function InteractiveMap() {
  const mapRef = useRef<HTMLDivElement>(null);
  const [map, setMap] = useState<LeafletMap | null>(null);
  const [selectedSegment, setSelectedSegment] = useState<any>(null);
  const [hoveredSegment, setHoveredSegment] = useState<any>(null);

  useEffect(() => {
    if (typeof window !== "undefined" && mapRef.current && !map) {
      import("leaflet")
        .then((L) => {
          if (mapRef.current && (mapRef.current as any)._leaflet_id) {
            return;
          }
          const mapInstance = L.map(mapRef.current!).setView(
            [-6.2088, 106.8456],
            12
          );

          L.tileLayer("https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png", {
            attribution: "© Kontributor OpenStreetMap",
          }).addTo(mapInstance);

          roadSegments.forEach((segment) => {
            const color =
              priorityColors[segment.priority as keyof typeof priorityColors];

            // Create markers for each coordinate point
            segment.coordinates.forEach((coordinate, index) => {
              const marker = L.circleMarker(coordinate as [number, number], {
                radius: 8,
                fillColor: color,
                color: "#fff",
                weight: 2,
                opacity: 1,
                fillOpacity: 0.8,
              }).addTo(mapInstance);

              // Create coordinate-specific data
              const coordinateData = {
                ...segment,
                coordinateIndex: index,
                coordinatePosition: coordinate,
                pointId: `${segment.id}-${index}`,
                pointName: `${segment.name} - Titik ${index + 1}`,
              };

              marker.on("click", () => {
                setSelectedSegment(coordinateData);
              });

              marker.on("mouseover", () => {
                setHoveredSegment(coordinateData);
                marker.setStyle({
                  radius: 10,
                  weight: 3,
                });
              });

              marker.on("mouseout", () => {
                setHoveredSegment(null);
                marker.setStyle({
                  radius: 8,
                  weight: 2,
                });
              });
            });
          });

          setMap(mapInstance);
        })
        .catch((error) => {
          console.error("Gagal memuat Leaflet:", error);
        });
    }

    return () => {
      if (map) {
        map.off();
        map.remove();
        setMap(null);
      }
    };
  }, []);

  const handleZoomIn = () => {
    if (map) {
      map.zoomIn();
    }
  };

  const handleZoomOut = () => {
    if (map) {
      map.zoomOut();
    }
  };

  const handleResetView = () => {
    if (map) {
      map.setView([-6.2088, 106.8456], 12);
    }
  };

  const handleFocusSegment = (segment: any) => {
    if (map) {
      const center =
        segment.coordinatePosition ||
        segment.coordinates[Math.floor(segment.coordinates.length / 2)];
      map.setView(center, 15);
      setSelectedSegment(segment);
    }
  };

  return (
    <Card className="w-full">
      <CardHeader>
        <div className="flex items-center justify-between">
          <div>
            <CardTitle>Peta Titik Koordinat Jalan</CardTitle>
            <CardDescription>
              Peta interaktif yang menampilkan titik-titik koordinat dengan
              informasi kondisi jalan dan tingkat prioritas
            </CardDescription>
          </div>
          <div className="flex gap-2">
            <Button variant="outline" size="sm" onClick={handleZoomIn}>
              <ZoomIn className="h-4 w-4" />
            </Button>
            <Button variant="outline" size="sm" onClick={handleZoomOut}>
              <ZoomOut className="h-4 w-4" />
            </Button>
            <Button variant="outline" size="sm" onClick={handleResetView}>
              <RotateCcw className="h-4 w-4" />
            </Button>
          </div>
        </div>
      </CardHeader>
      <CardContent className="space-y-4">
        {/* Legenda Peta */}
        <div className="flex flex-wrap items-center gap-4 p-3 bg-muted/30 rounded-lg border">
          <div className="flex items-center gap-2 text-sm font-medium">
            <MapPin className="h-4 w-4 text-primary" />
            <span className="hidden sm:inline">Legenda Titik Koordinat:</span>
            <span className="sm:hidden">Legenda:</span>
          </div>
          {Object.entries(priorityColors).map(([priority, color]) => (
            <div key={priority} className="flex items-center gap-2 text-sm">
              <div
                className="h-4 w-4 rounded-full border-2 border-white shadow-sm shrink-0"
                style={{ backgroundColor: color }}
              />
              <span className="hidden sm:inline">
                {priorityLabels[priority as keyof typeof priorityLabels]}
              </span>
              <span className="sm:hidden capitalize">{priority}</span>
            </div>
          ))}
        </div>

        {/* Peta */}
        <div className="relative w-full">
          <div
            ref={mapRef}
            className="h-[500px] w-full rounded-lg overflow-hidden border"
            style={{ minHeight: "500px", maxHeight: "500px" }}
          />

          {/* Tooltip Hover */}
          {hoveredSegment && (
            <div className="pointer-events-none absolute right-2 top-2 z-[1000] max-w-xs overflow-hidden rounded-lg border bg-white/95 shadow-lg backdrop-blur-sm">
              {/* Header */}
              <div className="border-b bg-white/50 px-3 py-2">
                <div className="flex items-center justify-between gap-2">
                  <h4 className="truncate text-sm font-semibold text-foreground">
                    {hoveredSegment.pointName || hoveredSegment.name}
                  </h4>
                  <Badge
                    variant={
                      hoveredSegment.priority === "high"
                        ? "destructive"
                        : hoveredSegment.priority === "medium"
                        ? "default"
                        : "secondary"
                    }
                    className="shrink-0 text-xs"
                  >
                    {
                      priorityLabels[
                        hoveredSegment.priority as keyof typeof priorityLabels
                      ]
                    }
                  </Badge>
                </div>
              </div>

              {/* Content */}
              <div className="p-3">
                <div className="space-y-3">
                  {/* Quick Stats */}
                  <div className="grid grid-cols-2 gap-3 text-xs">
                    <div className="space-y-1">
                      <p className="font-medium text-muted-foreground">Skor</p>
                      <p className="text-sm font-bold text-primary">
                        {hoveredSegment.priorityScore}
                      </p>
                    </div>
                    <div className="space-y-1">
                      <p className="font-medium text-muted-foreground">
                        Status
                      </p>
                      <p className="text-xs font-medium text-foreground">
                        {hoveredSegment.status}
                      </p>
                    </div>
                  </div>

                  {/* Coordinates */}
                  {hoveredSegment.coordinatePosition && (
                    <div className="space-y-1">
                      <p className="text-xs font-medium text-muted-foreground">
                        Koordinat
                      </p>
                      <p className="font-mono text-xs text-foreground">
                        {hoveredSegment.coordinatePosition[0].toFixed(4)},{" "}
                        {hoveredSegment.coordinatePosition[1].toFixed(4)}
                      </p>
                    </div>
                  )}

                  {/* Additional Info */}
                  <div className="grid gap-2 text-xs">
                    <div className="flex justify-between">
                      <span className="text-muted-foreground">Panjang:</span>
                      <span className="font-medium">
                        {hoveredSegment.length}
                      </span>
                    </div>
                    <div className="flex justify-between">
                      <span className="text-muted-foreground">Kerusakan:</span>
                      <span className="font-medium text-right">
                        {hoveredSegment.damageType}
                      </span>
                    </div>
                  </div>

                  {/* Preview Image */}
                  <div className="space-y-2">
                    <div className="flex items-center gap-1">
                      <div className="h-1 w-1 rounded-full bg-primary" />
                      <p className="text-xs font-medium text-muted-foreground">
                        Preview
                      </p>
                    </div>
                    <div className="aspect-video overflow-hidden rounded border bg-muted">
                      <img
                        src={`/Damaged road.jpeg`}
                        alt={`Preview for ${hoveredSegment.name}`}
                        className="h-full w-full object-cover"
                        onError={(e) => {
                          e.currentTarget.src = `data:image/svg+xml;base64,${btoa(`
                            <svg width="200" height="120" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 200 120">
                              <rect width="200" height="120" fill="#f3f4f6"/>
                              <g transform="translate(100, 60)">
                                <circle r="16" fill="#e5e7eb"/>
                                <path d="M -6 -6 L 6 6 M 6 -6 L -6 6" stroke="#9ca3af" stroke-width="1.5" stroke-linecap="round"/>
                              </g>
                              <text x="100" y="85" text-anchor="middle" font-family="ui-sans-serif" font-size="10" fill="#6b7280">
                                Preview
                              </text>
                            </svg>
                          `)}`;
                        }}
                      />
                    </div>
                  </div>
                </div>
              </div>
            </div>
          )}
        </div>

        {/* Daftar Titik Koordinat */}
        <div className="space-y-3">
          {roadSegments.map((segment) => (
            <div key={segment.id} className="space-y-3">
              <div className="p-3 rounded-lg border bg-card">
                <div className="flex items-center justify-between mb-2">
                  <h5 className="font-medium text-sm">{segment.name}</h5>
                  <div
                    className="h-3 w-3 rounded-full border border-white shadow-sm shrink-0"
                    style={{
                      backgroundColor:
                        priorityColors[
                          segment.priority as keyof typeof priorityColors
                        ],
                    }}
                  />
                </div>
                <div className="grid gap-1 sm:grid-cols-2 lg:grid-cols-3">
                  {segment.coordinates.map((coordinate, index) => {
                    const coordinateData = {
                      ...segment,
                      coordinateIndex: index,
                      coordinatePosition: coordinate,
                      pointId: `${segment.id}-${index}`,
                      pointName: `${segment.name} - Titik ${index + 1}`,
                    };
                    return (
                      <div
                        key={`${segment.id}-${index}`}
                        className={`p-2 rounded-md border cursor-pointer transition-all hover:shadow-sm hover:border-primary/50 text-xs ${
                          selectedSegment?.pointId === coordinateData.pointId
                            ? "ring-1 ring-primary bg-primary/5"
                            : "bg-background"
                        }`}
                        onClick={() => handleFocusSegment(coordinateData)}
                      >
                        <div className="flex items-center justify-between mb-1">
                          <span className="font-medium">Titik {index + 1}</span>
                          <div
                            className="h-2 w-2 rounded-full shrink-0"
                            style={{
                              backgroundColor:
                                priorityColors[
                                  segment.priority as keyof typeof priorityColors
                                ],
                            }}
                          />
                        </div>
                        <div className="text-xs text-muted-foreground">
                          <p>
                            {coordinate[0].toFixed(4)},{" "}
                            {coordinate[1].toFixed(4)}
                          </p>
                        </div>
                      </div>
                    );
                  })}
                </div>
              </div>

              {/* Detail Titik Terpilih - Show below the segment that contains the selected point */}
              {selectedSegment && selectedSegment.id === segment.id && (
                <div className="overflow-hidden rounded-lg border border-primary/20 bg-gradient-to-br from-primary/5 to-primary/10 shadow-sm">
                  {/* Header Section */}
                  <div className="border-b border-primary/10 bg-white/50 px-6 py-4">
                    <div className="flex flex-col gap-3 sm:flex-row sm:items-center sm:justify-between">
                      <div className="space-y-1">
                        <h4 className="text-xl font-semibold tracking-tight text-foreground">
                          {selectedSegment.pointName || selectedSegment.name}
                        </h4>
                        <p className="text-sm text-muted-foreground">
                          Detail informasi lokasi dan kondisi jalan
                        </p>
                      </div>
                      <Badge
                        variant="outline"
                        className="w-fit text-xs font-medium border-2"
                        style={{
                          backgroundColor:
                            priorityColors[
                              selectedSegment.priority as keyof typeof priorityColors
                            ],
                          borderColor:
                            priorityColors[
                              selectedSegment.priority as keyof typeof priorityColors
                            ],
                          color: "white",
                        }}
                      >
                        {
                          priorityLabels[
                            selectedSegment.priority as keyof typeof priorityLabels
                          ]
                        }
                      </Badge>
                    </div>
                  </div>

                  {/* Content Section */}
                  <div className="p-6">
                    <div className="grid gap-6 lg:grid-cols-3">
                      {/* Information Grid */}
                      <div className="lg:col-span-2">
                        <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
                          {/* Priority Score */}
                          <div className="rounded-lg border bg-card p-4 shadow-sm">
                            <div className="flex items-center gap-3">
                              <div className="rounded-full bg-black/10 p-2">
                                <div
                                  className="h-3 w-3 rounded-full"
                                  style={{
                                    backgroundColor:
                                      priorityColors[
                                        selectedSegment.priority as keyof typeof priorityColors
                                      ],
                                  }}
                                />
                              </div>
                              <div className="flex-1 space-y-1">
                                <p className="text-xs font-medium uppercase tracking-wide text-muted-foreground">
                                  Skor Prioritas
                                </p>
                                <p className="text-2xl font-bold text-foreground">
                                  {selectedSegment.priorityScore}
                                </p>
                              </div>
                            </div>
                          </div>

                          {/* Status */}
                          <div className="rounded-lg border bg-card p-4 shadow-sm">
                            <div className="space-y-2">
                              <p className="text-xs font-medium uppercase tracking-wide text-muted-foreground">
                                Status Saat Ini
                              </p>
                              <p className="text-sm font-semibold text-foreground">
                                {selectedSegment.status}
                              </p>
                            </div>
                          </div>

                          {/* Damage Type */}
                          <div className="rounded-lg border bg-card p-4 shadow-sm">
                            <div className="space-y-2">
                              <p className="text-xs font-medium uppercase tracking-wide text-muted-foreground">
                                Jenis Kerusakan
                              </p>
                              <p className="text-sm font-semibold text-foreground">
                                {selectedSegment.damageType}
                              </p>
                            </div>
                          </div>

                          {/* Coordinates */}
                          {selectedSegment.coordinatePosition && (
                            <div className="rounded-lg border bg-card p-4 shadow-sm">
                              <div className="space-y-2">
                                <p className="text-xs font-medium uppercase tracking-wide text-muted-foreground">
                                  Koordinat
                                </p>
                                <p className="font-mono text-xs text-foreground">
                                  {selectedSegment.coordinatePosition[0].toFixed(
                                    6
                                  )}
                                  ,{" "}
                                  {selectedSegment.coordinatePosition[1].toFixed(
                                    6
                                  )}
                                </p>
                              </div>
                            </div>
                          )}

                          {/* Last Inspection */}
                          <div className="rounded-lg border bg-card p-4 shadow-sm">
                            <div className="space-y-2">
                              <p className="text-xs font-medium uppercase tracking-wide text-muted-foreground">
                                Inspeksi Terakhir
                              </p>
                              <p className="text-sm font-semibold text-foreground">
                                {new Date(
                                  selectedSegment.lastInspection
                                ).toLocaleDateString("id-ID")}
                              </p>
                            </div>
                          </div>

                          {/* Segment Length */}
                          <div className="rounded-lg border bg-card p-4 shadow-sm">
                            <div className="space-y-2">
                              <p className="text-xs font-medium uppercase tracking-wide text-muted-foreground">
                                Panjang Segmen
                              </p>
                              <p className="text-sm font-semibold text-foreground">
                                {selectedSegment.length}
                              </p>
                            </div>
                          </div>
                        </div>
                      </div>

                      {/* Report Image */}
                      <div className="lg:col-span-1">
                        <div className="space-y-3">
                          <div className="flex items-center gap-2">
                            <div className="h-1 w-1 rounded-full bg-primary" />
                            <p className="text-xs font-medium uppercase tracking-wide text-muted-foreground">
                              Dokumentasi Lapangan
                            </p>
                          </div>
                          <div className="group relative aspect-video overflow-hidden rounded-lg border bg-muted shadow-sm transition-all hover:shadow-md">
                            <img
                              src={`/Damaged road.jpeg`}
                              alt={`Report image for ${
                                selectedSegment.pointName ||
                                selectedSegment.name
                              }`}
                              className="h-full w-full object-cover transition-transform group-hover:scale-105"
                              onError={(e) => {
                                e.currentTarget.src = `data:image/svg+xml;base64,${btoa(`
                                  <svg width="400" height="240" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 400 240">
                                    <defs>
                                      <pattern id="grid" width="20" height="20" patternUnits="userSpaceOnUse">
                                        <path d="M 20 0 L 0 0 0 20" fill="none" stroke="#e5e7eb" stroke-width="1"/>
                                      </pattern>
                                    </defs>
                                    <rect width="400" height="240" fill="#f9fafb"/>
                                    <rect width="400" height="240" fill="url(#grid)"/>
                                    <g transform="translate(200, 120)">
                                      <circle r="24" fill="#e5e7eb"/>
                                      <path d="M -8 -8 L 8 8 M 8 -8 L -8 8" stroke="#9ca3af" stroke-width="2" stroke-linecap="round"/>
                                    </g>
                                    <text x="200" y="160" text-anchor="middle" font-family="ui-sans-serif, system-ui" font-size="14" font-weight="500" fill="#6b7280">
                                      Gambar Tidak Tersedia
                                    </text>
                                  </svg>
                                `)}`;
                              }}
                            />
                            <div className="absolute inset-0 bg-gradient-to-t from-black/20 to-transparent opacity-0 transition-opacity group-hover:opacity-100" />
                          </div>
                          <p className="text-xs text-muted-foreground">
                            Klik gambar untuk melihat detail dokumentasi
                            lapangan
                          </p>
                        </div>
                      </div>
                    </div>
                  </div>
                </div>
              )}
            </div>
          ))}
        </div>
      </CardContent>
    </Card>
  );
}
