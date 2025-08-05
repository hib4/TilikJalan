"use client";

import { CalendarDays } from "lucide-react";
import {
  Bar,
  BarChart,
  Line,
  LineChart,
  Pie,
  PieChart,
  Cell,
  XAxis,
  YAxis,
  CartesianGrid,
  ResponsiveContainer,
  Legend,
} from "recharts";
import { Button } from "@/components/ui/button";
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import {
  ChartContainer,
  ChartTooltip,
  ChartTooltipContent,
} from "@/components/ui/chart";

const reportsOverTime = [
  { date: "2024-01-01", reports: 12 },
  { date: "2024-01-02", reports: 8 },
  { date: "2024-01-03", reports: 15 },
  { date: "2024-01-04", reports: 10 },
  { date: "2024-01-05", reports: 18 },
  { date: "2024-01-06", reports: 22 },
  { date: "2024-01-07", reports: 14 },
  { date: "2024-01-08", reports: 16 },
  { date: "2024-01-09", reports: 20 },
  { date: "2024-01-10", reports: 25 },
  { date: "2024-01-11", reports: 19 },
  { date: "2024-01-12", reports: 23 },
  { date: "2024-01-13", reports: 17 },
  { date: "2024-01-14", reports: 21 },
  { date: "2024-01-15", reports: 28 },
  { date: "2024-01-16", reports: 24 },
  { date: "2024-01-17", reports: 26 },
  { date: "2024-01-18", reports: 30 },
  { date: "2024-01-19", reports: 27 },
  { date: "2024-01-20", reports: 32 },
  { date: "2024-01-21", reports: 29 },
  { date: "2024-01-22", reports: 35 },
  { date: "2024-01-23", reports: 31 },
  { date: "2024-01-24", reports: 38 },
  { date: "2024-01-25", reports: 33 },
  { date: "2024-01-26", reports: 40 },
  { date: "2024-01-27", reports: 36 },
  { date: "2024-01-28", reports: 42 },
  { date: "2024-01-29", reports: 39 },
  { date: "2024-01-30", reports: 45 },
];

const damageTypes = [
  { type: "Lubang Jalan", count: 145, fill: "#007AFF" },
  { type: "Retakan", count: 98, fill: "#FF9500" },
  { type: "Aus Permukaan", count: 76, fill: "#34C759" },
  { type: "Kerusakan Air", count: 54, fill: "#FF3B30" },
  { type: "Kerusakan Pinggir", count: 32, fill: "#AF52DE" },
  { type: "Potongan Utilitas", count: 28, fill: "#FF9F0A" },
];

const taskStatus = [
  { name: "Prioritas Baru", value: 45, fill: "#FF3B30" },
  { name: "Tim Survei Dikirim", value: 32, fill: "#FF9500" },
  { name: "Pemeliharaan Terjadwal", value: 28, fill: "#007AFF" },
  { name: "Selesai", value: 95, fill: "#34C759" },
];

const chartConfig = {
  reports: {
    label: "Laporan",
    color: "#007AFF",
  },
  count: {
    label: "Jumlah",
    color: "#007AFF",
  },
  value: {
    label: "Tugas",
    color: "#007AFF",
  },
};

export function AnalyticsPage() {
  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-bold tracking-tight">
            Analitik & Laporan
          </h1>
          <p className="text-muted-foreground">
            Lihat data historis dan tren untuk aktivitas pemeliharaan jalan
          </p>
        </div>
        <Button variant="outline" className="gap-2 bg-transparent">
          <CalendarDays className="h-4 w-4" />
          30 Hari Terakhir
        </Button>
      </div>

      <div className="grid gap-6">
        <Card>
          <CardHeader>
            <CardTitle>
              Laporan Prioritas Tinggi dari Waktu ke Waktu (30 Hari Terakhir)
            </CardTitle>
            <CardDescription>
              Analisis tren laporan pemeliharaan jalan prioritas tinggi
            </CardDescription>
          </CardHeader>
          <CardContent>
            <ChartContainer config={chartConfig} className="h-80 w-full">
              <ResponsiveContainer width="100%" height="100%">
                <LineChart
                  data={reportsOverTime}
                  margin={{ top: 5, right: 30, left: 20, bottom: 5 }}
                >
                  <CartesianGrid
                    strokeDasharray="3 3"
                    className="stroke-muted"
                  />
                  <XAxis
                    dataKey="date"
                    className="text-xs"
                    tickFormatter={(value) =>
                      new Date(value).getDate().toString()
                    }
                  />
                  <YAxis className="text-xs" />
                  <ChartTooltip
                    content={<ChartTooltipContent />}
                    labelFormatter={(value) =>
                      new Date(value).toLocaleDateString("id-ID")
                    }
                  />
                  <Line
                    type="monotone"
                    dataKey="reports"
                    stroke="#007AFF"
                    strokeWidth={2}
                    dot={{ fill: "#007AFF", strokeWidth: 2, r: 4 }}
                    activeDot={{ r: 6, stroke: "#007AFF", strokeWidth: 2 }}
                  />
                </LineChart>
              </ResponsiveContainer>
            </ChartContainer>
          </CardContent>
        </Card>

        <div className="grid gap-6 md:grid-cols-2">
          <Card>
            <CardHeader>
              <CardTitle>Jenis Kerusakan Jalan Paling Umum</CardTitle>
              <CardDescription>
                Distribusi berbagai jenis kerusakan jalan yang dilaporkan
              </CardDescription>
            </CardHeader>
            <CardContent>
              <ChartContainer config={chartConfig} className="h-64 w-full">
                <ResponsiveContainer width="100%" height="100%">
                  <BarChart
                    data={damageTypes}
                    margin={{ top: 20, right: 30, left: 20, bottom: 5 }}
                  >
                    <CartesianGrid
                      strokeDasharray="3 3"
                      className="stroke-muted"
                    />
                    <XAxis
                      dataKey="type"
                      className="text-xs"
                      angle={-45}
                      textAnchor="end"
                      height={80}
                    />
                    <YAxis className="text-xs" />
                    <ChartTooltip content={<ChartTooltipContent />} />
                    <Bar dataKey="count" radius={[4, 4, 0, 0]}>
                      {damageTypes.map((entry, index) => (
                        <Cell key={`cell-${index}`} fill={entry.fill} />
                      ))}
                    </Bar>
                  </BarChart>
                </ResponsiveContainer>
              </ChartContainer>
            </CardContent>
          </Card>

          <Card>
            <CardHeader>
              <CardTitle>Status Tugas Keseluruhan</CardTitle>
              <CardDescription>
                Distribusi tugas saat ini di berbagai tahap
              </CardDescription>
            </CardHeader>
            <CardContent>
              <ChartContainer config={chartConfig} className="h-64 w-full">
                <ResponsiveContainer width="100%" height="100%">
                  <PieChart>
                    <Pie
                      data={taskStatus}
                      cx="50%"
                      cy="50%"
                      innerRadius={40}
                      outerRadius={80}
                      paddingAngle={2}
                      dataKey="value"
                    >
                      {taskStatus.map((entry, index) => (
                        <Cell key={`cell-${index}`} fill={entry.fill} />
                      ))}
                    </Pie>
                    <ChartTooltip
                      content={<ChartTooltipContent />}
                      formatter={(value, name) => [value, name]}
                    />
                    <Legend
                      verticalAlign="bottom"
                      height={36}
                      formatter={(value) => (
                        <span className="text-sm">{value}</span>
                      )}
                    />
                  </PieChart>
                </ResponsiveContainer>
              </ChartContainer>
            </CardContent>
          </Card>
        </div>
      </div>
    </div>
  );
}
