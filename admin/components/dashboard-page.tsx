"use client";

import { AlertTriangle, CheckCircle, Clock, Eye } from "lucide-react";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import { InteractiveMap } from "@/components/interactive-map";

const priorityHotspots = [
  {
    streetName: "Jl. Sudirman",
    priorityScore: 9.5,
    status: "Baru",
    id: 1,
  },
  {
    streetName: "Jl. Thamrin",
    priorityScore: 9.2,
    status: "Sedang Ditinjau",
    id: 2,
  },
  {
    streetName: "Jl. Gatot Subroto",
    priorityScore: 8.8,
    status: "Baru",
    id: 3,
  },
  {
    streetName: "Jl. Rasuna Said",
    priorityScore: 8.5,
    status: "Sedang Ditinjau",
    id: 4,
  },
  {
    streetName: "Jl. Kuningan",
    priorityScore: 8.1,
    status: "Baru",
    id: 5,
  },
];

export function DashboardPage() {
  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-3xl font-bold tracking-tight">Dasbor</h1>
        <p className="text-muted-foreground">
          Pantau kondisi jalan dan aktivitas perbaikan di seluruh kota
        </p>
      </div>

      {/* Kartu Metrik Utama */}
      <div className="grid gap-4 md:grid-cols-3">
        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">
              Total Segmen Prioritas Tinggi
            </CardTitle>
            <AlertTriangle className="h-4 w-4 text-orange-500" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">127</div>
            <p className="text-xs text-muted-foreground">
              +12% dari bulan lalu
            </p>
          </CardContent>
        </Card>
        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">
              Laporan Baru Hari Ini
            </CardTitle>
            <Clock className="h-4 w-4 text-primary" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">23</div>
            <p className="text-xs text-muted-foreground">+5 dari kemarin</p>
          </CardContent>
        </Card>
        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">
              Perbaikan Sedang Berlangsung
            </CardTitle>
            <CheckCircle className="h-4 w-4 text-green-500" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">45</div>
            <p className="text-xs text-muted-foreground">8 selesai hari ini</p>
          </CardContent>
        </Card>
      </div>

      {/* Peta Interaktif */}
      <div className="w-full">
        <InteractiveMap />
      </div>

      {/* Tabel Titik Prioritas */}
      <div className="mt-6">
        <Card>
          <CardHeader>
            <CardTitle>Titik Prioritas</CardTitle>
            <CardDescription>
              5 segmen jalan paling kritis yang memerlukan perhatian segera
            </CardDescription>
          </CardHeader>
          <CardContent>
            <div className="overflow-x-auto">
              <Table>
                <TableHeader>
                  <TableRow>
                    <TableHead>Nama Jalan</TableHead>
                    <TableHead>Skor Prioritas</TableHead>
                    <TableHead>Status</TableHead>
                    <TableHead>Aksi</TableHead>
                  </TableRow>
                </TableHeader>
                <TableBody>
                  {priorityHotspots.map((hotspot) => (
                    <TableRow
                      key={hotspot.id}
                      className={
                        hotspot.priorityScore > 9.0
                          ? "bg-orange-50 hover:bg-orange-100"
                          : ""
                      }
                    >
                      <TableCell className="font-medium">
                        {hotspot.streetName}
                      </TableCell>
                      <TableCell>
                        <span className="font-mono text-sm">
                          {hotspot.priorityScore}
                        </span>
                      </TableCell>
                      <TableCell>
                        <Badge
                          variant={
                            hotspot.status === "Baru"
                              ? "destructive"
                              : "secondary"
                          }
                        >
                          {hotspot.status}
                        </Badge>
                      </TableCell>
                      <TableCell>
                        <Button size="sm" variant="outline">
                          <Eye className="h-3 w-3 mr-1" />
                          Lihat
                        </Button>
                      </TableCell>
                    </TableRow>
                  ))}
                </TableBody>
              </Table>
            </div>
          </CardContent>
        </Card>
      </div>
    </div>
  );
}
