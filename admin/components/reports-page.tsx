"use client";

import { useState } from "react";
import { 
  AlertTriangle, 
  CheckCircle, 
  Clock, 
  Eye, 
  Filter,
  MapPin,
  Camera,
  Calendar,
  User
} from "lucide-react";
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
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from "@/components/ui/dialog";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";

// Mock data for road damage reports
const mockReports = [
  {
    id: 1,
    title: "Jalan Berlubang Besar",
    description: "Terdapat lubang besar di tengah jalan yang dapat membahayakan pengendara",
    location: "Jl. Sudirman No. 123, Jakarta Pusat",
    coordinates: { lat: -6.2088, lng: 106.8456 },
    photoUrl: "/placeholder.jpg",
    status: "Baru",
    priority: "Tinggi",
    reportedBy: "Ahmad Wijaya",
    reportedAt: "2024-01-15 09:30",
    category: "Lubang"
  },
  {
    id: 2,
    title: "Aspal Terkelupas",
    description: "Aspal terkelupas sepanjang 50 meter, permukaan jalan tidak rata",
    location: "Jl. Thamrin No. 45, Jakarta Pusat",
    coordinates: { lat: -6.1944, lng: 106.8229 },
    photoUrl: "/placeholder.jpg",
    status: "Sedang Ditinjau",
    priority: "Sedang",
    reportedBy: "Siti Nurhaliza",
    reportedAt: "2024-01-14 14:15",
    category: "Kerusakan Permukaan"
  },
  {
    id: 3,
    title: "Drainase Tersumbat",
    description: "Drainase di pinggir jalan tersumbat menyebabkan genangan air",
    location: "Jl. Gatot Subroto KM 5, Jakarta Selatan",
    coordinates: { lat: -6.2297, lng: 106.8253 },
    photoUrl: "/placeholder.jpg",
    status: "Dalam Perbaikan",
    priority: "Tinggi",
    reportedBy: "Budi Santoso",
    reportedAt: "2024-01-13 11:45",
    category: "Drainase"
  },
  {
    id: 4,
    title: "Retak Halus di Jalan",
    description: "Terdapat retakan halus yang mulai melebar",
    location: "Jl. Rasuna Said No. 78, Jakarta Selatan",
    coordinates: { lat: -6.2245, lng: 106.8412 },
    photoUrl: "/placeholder.jpg",
    status: "Selesai",
    priority: "Rendah",
    reportedBy: "Maria Santos",
    reportedAt: "2024-01-12 16:20",
    category: "Retak"
  },
  {
    id: 5,
    title: "Marka Jalan Pudar",
    description: "Marka jalan sudah sangat pudar dan sulit terlihat",
    location: "Jl. Kuningan Raya No. 12, Jakarta Selatan",
    coordinates: { lat: -6.2384, lng: 106.8305 },
    photoUrl: "/placeholder.jpg",
    status: "Baru",
    priority: "Sedang",
    reportedBy: "Andi Pratama",
    reportedAt: "2024-01-11 08:10",
    category: "Marka"
  }
];

const statusOptions = [
  { value: "Baru", label: "Baru" },
  { value: "Sedang Ditinjau", label: "Sedang Ditinjau" },
  { value: "Dalam Perbaikan", label: "Dalam Perbaikan" },
  { value: "Selesai", label: "Selesai" },
  { value: "Ditolak", label: "Ditolak" }
];

const getStatusVariant = (status: string) => {
  switch (status) {
    case "Baru":
      return "destructive";
    case "Sedang Ditinjau":
      return "secondary";
    case "Dalam Perbaikan":
      return "default";
    case "Selesai":
      return "outline";
    case "Ditolak":
      return "destructive";
    default:
      return "secondary";
  }
};

const getPriorityColor = (priority: string) => {
  switch (priority) {
    case "Tinggi":
      return "text-red-600";
    case "Sedang":
      return "text-yellow-600";
    case "Rendah":
      return "text-green-600";
    default:
      return "text-gray-600";
  }
};

export function ReportsPage() {
  const [reports, setReports] = useState(mockReports);
  const [statusFilter, setStatusFilter] = useState<string>("all");
  const [priorityFilter, setPriorityFilter] = useState<string>("all");

  const updateReportStatus = (reportId: number, newStatus: string) => {
    setReports(prev => 
      prev.map(report => 
        report.id === reportId 
          ? { ...report, status: newStatus }
          : report
      )
    );
  };

  const filteredReports = reports.filter(report => {
    const statusMatch = statusFilter === "all" || report.status === statusFilter;
    const priorityMatch = priorityFilter === "all" || report.priority === priorityFilter;
    return statusMatch && priorityMatch;
  });

  const getStatusCounts = () => {
    const counts = reports.reduce((acc, report) => {
      acc[report.status] = (acc[report.status] || 0) + 1;
      return acc;
    }, {} as Record<string, number>);
    
    return {
      baru: counts["Baru"] || 0,
      sedangDitinjau: counts["Sedang Ditinjau"] || 0,
      dalamPerbaikan: counts["Dalam Perbaikan"] || 0,
      selesai: counts["Selesai"] || 0
    };
  };

  const statusCounts = getStatusCounts();

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-3xl font-bold tracking-tight">Laporan</h1>
        <p className="text-muted-foreground">
          Kelola laporan kerusakan jalan yang dikirim oleh pengguna
        </p>
      </div>

      {/* Kartu Statistik */}
      <div className="grid gap-4 md:grid-cols-4">
        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Laporan Baru</CardTitle>
            <AlertTriangle className="h-4 w-4 text-red-500" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{statusCounts.baru}</div>
            <p className="text-xs text-muted-foreground">Memerlukan tinjauan</p>
          </CardContent>
        </Card>
        
        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Sedang Ditinjau</CardTitle>
            <Clock className="h-4 w-4 text-yellow-500" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{statusCounts.sedangDitinjau}</div>
            <p className="text-xs text-muted-foreground">Dalam proses review</p>
          </CardContent>
        </Card>
        
        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Dalam Perbaikan</CardTitle>
            <Clock className="h-4 w-4 text-blue-500" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{statusCounts.dalamPerbaikan}</div>
            <p className="text-xs text-muted-foreground">Sedang diperbaiki</p>
          </CardContent>
        </Card>
        
        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Selesai</CardTitle>
            <CheckCircle className="h-4 w-4 text-green-500" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{statusCounts.selesai}</div>
            <p className="text-xs text-muted-foreground">Perbaikan selesai</p>
          </CardContent>
        </Card>
      </div>

      {/* Filter dan Tabel Laporan */}
      <Card>
        <CardHeader>
          <div className="flex flex-col sm:flex-row gap-4 items-start sm:items-center justify-between">
            <div>
              <CardTitle>Daftar Laporan</CardTitle>
              <CardDescription>
                Kelola dan update status laporan kerusakan jalan
              </CardDescription>
            </div>
            <div className="flex gap-2">
              <Select value={statusFilter} onValueChange={setStatusFilter}>
                <SelectTrigger className="w-[160px]">
                  <SelectValue placeholder="Filter Status" />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="all">Semua Status</SelectItem>
                  <SelectItem value="Baru">Baru</SelectItem>
                  <SelectItem value="Sedang Ditinjau">Sedang Ditinjau</SelectItem>
                  <SelectItem value="Dalam Perbaikan">Dalam Perbaikan</SelectItem>
                  <SelectItem value="Selesai">Selesai</SelectItem>
                  <SelectItem value="Ditolak">Ditolak</SelectItem>
                </SelectContent>
              </Select>
              
              <Select value={priorityFilter} onValueChange={setPriorityFilter}>
                <SelectTrigger className="w-[160px]">
                  <SelectValue placeholder="Filter Prioritas" />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="all">Semua Prioritas</SelectItem>
                  <SelectItem value="Tinggi">Tinggi</SelectItem>
                  <SelectItem value="Sedang">Sedang</SelectItem>
                  <SelectItem value="Rendah">Rendah</SelectItem>
                </SelectContent>
              </Select>
            </div>
          </div>
        </CardHeader>
        <CardContent>
          <div className="overflow-x-auto">
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead>Judul</TableHead>
                  <TableHead>Lokasi</TableHead>
                  <TableHead>Prioritas</TableHead>
                  <TableHead>Status</TableHead>
                  <TableHead>Pelapor</TableHead>
                  <TableHead>Tanggal</TableHead>
                  <TableHead>Aksi</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {filteredReports.map((report) => (
                  <TableRow key={report.id}>
                    <TableCell className="font-medium">
                      {report.title}
                    </TableCell>
                    <TableCell className="max-w-[200px]">
                      <div className="flex items-center gap-1">
                        <MapPin className="h-3 w-3 text-muted-foreground" />
                        <span className="truncate text-sm">{report.location}</span>
                      </div>
                    </TableCell>
                    <TableCell>
                      <span className={`text-sm font-medium ${getPriorityColor(report.priority)}`}>
                        {report.priority}
                      </span>
                    </TableCell>
                    <TableCell>
                      <div className="flex items-center gap-2">
                        <Badge variant={getStatusVariant(report.status)}>
                          {report.status}
                        </Badge>
                      </div>
                    </TableCell>
                    <TableCell>
                      <div className="flex items-center gap-1">
                        <User className="h-3 w-3 text-muted-foreground" />
                        <span className="text-sm">{report.reportedBy}</span>
                      </div>
                    </TableCell>
                    <TableCell>
                      <div className="flex items-center gap-1">
                        <Calendar className="h-3 w-3 text-muted-foreground" />
                        <span className="text-sm">{report.reportedAt}</span>
                      </div>
                    </TableCell>
                    <TableCell>
                      <Dialog>
                        <DialogTrigger asChild>
                          <Button size="sm" variant="outline">
                            <Eye className="h-3 w-3 mr-1" />
                            Detail
                          </Button>
                        </DialogTrigger>
                        <DialogContent className="max-w-2xl">
                          <DialogHeader>
                            <DialogTitle>{report.title}</DialogTitle>
                            <DialogDescription>
                              Detail laporan kerusakan jalan
                            </DialogDescription>
                          </DialogHeader>
                          <div className="grid gap-4">
                            <div className="grid grid-cols-2 gap-4">
                              <div>
                                <label className="text-sm font-medium">Kategori</label>
                                <p className="text-sm text-muted-foreground">{report.category}</p>
                              </div>
                              <div>
                                <label className="text-sm font-medium">Prioritas</label>
                                <p className={`text-sm font-medium ${getPriorityColor(report.priority)}`}>
                                  {report.priority}
                                </p>
                              </div>
                            </div>
                            
                            <div>
                              <label className="text-sm font-medium">Deskripsi</label>
                              <p className="text-sm text-muted-foreground mt-1">{report.description}</p>
                            </div>
                            
                            <div>
                              <label className="text-sm font-medium">Lokasi</label>
                              <div className="flex items-center gap-1 mt-1">
                                <MapPin className="h-4 w-4 text-muted-foreground" />
                                <p className="text-sm text-muted-foreground">{report.location}</p>
                              </div>
                            </div>
                            
                            <div>
                              <label className="text-sm font-medium">Foto Kerusakan</label>
                              <div className="mt-2 relative">
                                <img 
                                  src={report.photoUrl} 
                                  alt="Foto kerusakan jalan"
                                  className="w-full h-48 object-cover rounded-lg border"
                                />
                                <div className="absolute top-2 right-2">
                                  <Camera className="h-4 w-4 text-white" />
                                </div>
                              </div>
                            </div>
                            
                            <div className="grid grid-cols-2 gap-4">
                              <div>
                                <label className="text-sm font-medium">Pelapor</label>
                                <div className="flex items-center gap-1 mt-1">
                                  <User className="h-4 w-4 text-muted-foreground" />
                                  <p className="text-sm text-muted-foreground">{report.reportedBy}</p>
                                </div>
                              </div>
                              <div>
                                <label className="text-sm font-medium">Tanggal Laporan</label>
                                <div className="flex items-center gap-1 mt-1">
                                  <Calendar className="h-4 w-4 text-muted-foreground" />
                                  <p className="text-sm text-muted-foreground">{report.reportedAt}</p>
                                </div>
                              </div>
                            </div>
                            
                            <div>
                              <label className="text-sm font-medium">Update Status</label>
                              <Select 
                                value={report.status} 
                                onValueChange={(value) => updateReportStatus(report.id, value)}
                              >
                                <SelectTrigger className="w-full mt-1">
                                  <SelectValue />
                                </SelectTrigger>
                                <SelectContent>
                                  {statusOptions.map((option) => (
                                    <SelectItem key={option.value} value={option.value}>
                                      {option.label}
                                    </SelectItem>
                                  ))}
                                </SelectContent>
                              </Select>
                            </div>
                          </div>
                        </DialogContent>
                      </Dialog>
                    </TableCell>
                  </TableRow>
                ))}
              </TableBody>
            </Table>
          </div>
        </CardContent>
      </Card>
    </div>
  );
}
