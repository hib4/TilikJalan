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
            <div className="absolute top-2 right-2 z-[1000] bg-white p-3 rounded-lg shadow-lg border max-w-xs pointer-events-none">
              <div className="space-y-2">
                <div className="flex items-center justify-between gap-2">
                  <h4 className="font-semibold text-sm truncate">
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
                <div className="text-xs text-muted-foreground space-y-1">
                  <p>
                    <strong>Skor:</strong> {hoveredSegment.priorityScore}
                  </p>
                  <p>
                    <strong>Status:</strong> {hoveredSegment.status}
                  </p>
                  {hoveredSegment.coordinatePosition && (
                    <p>
                      <strong>Koordinat:</strong>{" "}
                      {hoveredSegment.coordinatePosition[0].toFixed(4)},{" "}
                      {hoveredSegment.coordinatePosition[1].toFixed(4)}
                    </p>
                  )}
                  <p>
                    <strong>Panjang:</strong> {hoveredSegment.length}
                  </p>
                  <p>
                    <strong>Jenis Kerusakan:</strong>{" "}
                    {hoveredSegment.damageType}
                  </p>
                </div>
              </div>
            </div>
          )}
        </div>

        {/* Daftar Titik Koordinat */}
        <div className="space-y-3">
          {roadSegments.map((segment) => (
            <div key={segment.id} className="p-3 rounded-lg border bg-card">
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
                          {coordinate[0].toFixed(4)}, {coordinate[1].toFixed(4)}
                        </p>
                      </div>
                    </div>
                  );
                })}
              </div>
            </div>
          ))}
        </div>

        {/* Detail Titik Terpilih */}
        {selectedSegment && (
          <div className="p-4 bg-primary/5 rounded-lg border border-primary/20">
            <div className="flex items-center justify-between mb-3">
              <h4 className="font-semibold text-lg">
                {selectedSegment.pointName || selectedSegment.name}
              </h4>
              <Badge
                variant={
                  selectedSegment.priority === "high"
                    ? "destructive"
                    : selectedSegment.priority === "medium"
                    ? "default"
                    : "secondary"
                }
              >
                {
                  priorityLabels[
                    selectedSegment.priority as keyof typeof priorityLabels
                  ]
                }
              </Badge>
            </div>
            <div className="grid gap-3 md:grid-cols-2 lg:grid-cols-4 text-sm">
              <div>
                <p className="font-medium text-muted-foreground">
                  Skor Prioritas
                </p>
                <p className="text-lg font-semibold">
                  {selectedSegment.priorityScore}
                </p>
              </div>
              <div>
                <p className="font-medium text-muted-foreground">
                  Status Saat Ini
                </p>
                <p>{selectedSegment.status}</p>
              </div>
              {selectedSegment.coordinatePosition && (
                <div>
                  <p className="font-medium text-muted-foreground">Koordinat</p>
                  <p className="font-mono text-xs">
                    {selectedSegment.coordinatePosition[0].toFixed(6)},{" "}
                    {selectedSegment.coordinatePosition[1].toFixed(6)}
                  </p>
                </div>
              )}
              <div>
                <p className="font-medium text-muted-foreground">
                  Jenis Kerusakan
                </p>
                <p>{selectedSegment.damageType}</p>
              </div>
              <div>
                <p className="font-medium text-muted-foreground">
                  Inspeksi Terakhir
                </p>
                <p>
                  {new Date(selectedSegment.lastInspection).toLocaleDateString(
                    "id-ID"
                  )}
                </p>
              </div>
              <div>
                <p className="font-medium text-muted-foreground">
                  Panjang Segmen
                </p>
                <p>{selectedSegment.length}</p>
              </div>
            </div>
          </div>
        )}
      </CardContent>
    </Card>
  );
}
