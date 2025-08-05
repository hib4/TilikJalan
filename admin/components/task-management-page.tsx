"use client";

import { useState, useCallback } from "react";
import { DndProvider } from "react-dnd";
import { HTML5Backend } from "react-dnd-html5-backend";
import { TouchBackend } from "react-dnd-touch-backend";
import { GripVertical, CheckCircle2 } from "lucide-react";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { useToast } from "@/hooks/use-toast";
import { DraggableTask } from "@/components/draggable-task";
import { DroppableColumn } from "@/components/droppable-column";

const isTouchDevice = () => {
  if (typeof window === "undefined") return false;
  return "ontouchstart" in window || navigator.maxTouchPoints > 0;
};

const initialKanbanData = {
  "new-priority": {
    title: "Prioritas Baru",
    tasks: [
      {
        id: "task-1",
        streetName: "Jl. Sudirman Raya",
        priorityScore: 9.5,
        team: ["JD", "SM", "AB"],
        isHighPriority: true,
        status: "Baru",
        assignedDate: "2024-01-15",
        estimatedDuration: "3 hari",
      },
      {
        id: "task-2",
        streetName: "Jl. Kuningan Timur",
        priorityScore: 8.1,
        team: ["AB", "CD"],
        isHighPriority: false,
        status: "Baru",
        assignedDate: "2024-01-14",
        estimatedDuration: "2 hari",
      },
    ],
  },
  "survey-dispatched": {
    title: "Tim Survei Dikirim",
    tasks: [
      {
        id: "task-3",
        streetName: "Jl. Thamrin Boulevard",
        priorityScore: 9.2,
        team: ["EF", "GH", "IJ", "KL"],
        isHighPriority: true,
        status: "Sedang Berlangsung",
        assignedDate: "2024-01-13",
        estimatedDuration: "4 hari",
      },
      {
        id: "task-4",
        streetName: "Jl. Senayan City Center",
        priorityScore: 7.8,
        team: ["IJ", "KL"],
        isHighPriority: false,
        status: "Sedang Berlangsung",
        assignedDate: "2024-01-12",
        estimatedDuration: "2 hari",
      },
    ],
  },
  "maintenance-scheduled": {
    title: "Pemeliharaan Terjadwal",
    tasks: [
      {
        id: "task-5",
        streetName: "Jl. Gatot Subroto Extension",
        priorityScore: 8.8,
        team: ["MN", "OP"],
        isHighPriority: false,
        status: "Dijadwalkan",
        assignedDate: "2024-01-11",
        estimatedDuration: "5 hari",
      },
    ],
  },
  completed: {
    title: "Selesai",
    tasks: [
      {
        id: "task-6",
        streetName: "Jl. Rasuna Said Kav",
        priorityScore: 8.5,
        team: ["QR", "ST"],
        isHighPriority: false,
        status: "Selesai",
        assignedDate: "2024-01-08",
        estimatedDuration: "3 hari",
      },
      {
        id: "task-7",
        streetName: "Jl. Casablanca Raya",
        priorityScore: 7.2,
        team: ["UV", "WX", "YZ"],
        isHighPriority: false,
        status: "Selesai",
        assignedDate: "2024-01-05",
        estimatedDuration: "2 hari",
      },
    ],
  },
};

export function TaskManagementPage() {
  const [kanbanData, setKanbanData] = useState(initialKanbanData);
  const [draggedTask, setDraggedTask] = useState<string | null>(null);
  const [isAutoSaving, setIsAutoSaving] = useState(false);
  const { toast } = useToast();

  const moveTask = useCallback(
    (
      taskId: string,
      sourceColumnId: string,
      targetColumnId: string,
      targetIndex: number
    ) => {
      setIsAutoSaving(true);

      setKanbanData((prevData) => {
        const newData = { ...prevData };

        const sourceColumn = newData[sourceColumnId as keyof typeof newData];
        const taskIndex = sourceColumn.tasks.findIndex(
          (task) => task.id === taskId
        );
        const [movedTask] = sourceColumn.tasks.splice(taskIndex, 1);

        const statusMap: { [key: string]: string } = {
          "new-priority": "Baru",
          "survey-dispatched": "Sedang Berlangsung",
          "maintenance-scheduled": "Dijadwalkan",
          completed: "Selesai",
        };
        movedTask.status = statusMap[targetColumnId] || movedTask.status;

        const targetColumn = newData[targetColumnId as keyof typeof newData];
        targetColumn.tasks.splice(targetIndex, 0, movedTask);

        return newData;
      });

      setTimeout(() => {
        setIsAutoSaving(false);
        toast({
          title: "Tugas Diperbarui",
          description: "Posisi tugas telah tersimpan otomatis.",
          duration: 2000,
        });
      }, 1000);
    },
    [toast]
  );

  const handleDragStart = useCallback((taskId: string) => {
    setDraggedTask(taskId);
  }, []);

  const handleDragEnd = useCallback(() => {
    setDraggedTask(null);
  }, []);

  const backend = isTouchDevice() ? TouchBackend : HTML5Backend;

  return (
    <DndProvider backend={backend}>
      <div className="space-y-6">
        <div className="flex items-center justify-between">
          <div>
            <h1 className="text-3xl font-bold tracking-tight">
              Manajemen
            </h1>
            <p className="text-muted-foreground">
              Kelola tugas perbaikan jalan melalui alur perbaikan
            </p>
          </div>
          <div className="flex items-center gap-2">
            {isAutoSaving && (
              <div className="flex items-center gap-2 text-sm text-muted-foreground">
                <div className="h-4 w-4 animate-spin rounded-full border-2 border-primary border-t-transparent" />
                <span>Menyimpan otomatis...</span>
              </div>
            )}
            <Button variant="outline" size="sm">
              <CheckCircle2 className="h-4 w-4 mr-2" />
              Semua Perubahan Tersimpan
            </Button>
          </div>
        </div>

        {/* Petunjuk Drag & Drop */}
        <div className="bg-blue-50 border border-blue-200 rounded-lg p-4">
          <div className="flex items-start gap-3">
            <GripVertical className="h-5 w-5 text-blue-600 mt-0.5 shrink-0" />
            <div>
              <h3 className="font-medium text-blue-900">
                Petunjuk Seret & Lepas
              </h3>
              <p className="text-sm text-blue-700 mt-1">
                Klik dan seret tugas antar kolom untuk memperbarui statusnya.
                Tugas akan otomatis tersimpan saat dipindahkan. Gunakan pegangan
                atau seret dari area mana pun pada kartu tugas.
              </p>
            </div>
          </div>
        </div>

        {/* Papan Kanban */}
        <div className="grid gap-4 md:gap-6 grid-cols-1 md:grid-cols-2 lg:grid-cols-4">
          {Object.entries(kanbanData).map(([columnId, column]) => (
            <DroppableColumn
              key={columnId}
              columnId={columnId}
              title={column.title}
              taskCount={column.tasks.length}
              onMoveTask={moveTask}
            >
              <div className="space-y-3">
                {column.tasks.map((task, index) => (
                  <DraggableTask
                    key={task.id}
                    task={task}
                    index={index}
                    columnId={columnId}
                    isDragging={draggedTask === task.id}
                    onDragStart={handleDragStart}
                    onDragEnd={handleDragEnd}
                  />
                ))}
                {column.tasks.length === 0 && (
                  <div className="flex items-center justify-center h-24 border-2 border-dashed border-muted-foreground/25 rounded-lg bg-muted/20">
                    <p className="text-sm text-muted-foreground">
                      Letakkan tugas di sini
                    </p>
                  </div>
                )}
              </div>
            </DroppableColumn>
          ))}
        </div>

        {/* Statistik Tugas */}
        <div className="grid gap-4 md:grid-cols-4">
          <Card>
            <CardHeader className="pb-2">
              <CardTitle className="text-sm font-medium">Total Tugas</CardTitle>
            </CardHeader>
            <CardContent>
              <div className="text-2xl font-bold">
                {Object.values(kanbanData).reduce(
                  (total, column) => total + column.tasks.length,
                  0
                )}
              </div>
            </CardContent>
          </Card>
          <Card>
            <CardHeader className="pb-2">
              <CardTitle className="text-sm font-medium">
                Prioritas Tinggi
              </CardTitle>
            </CardHeader>
            <CardContent>
              <div className="text-2xl font-bold text-red-600">
                {Object.values(kanbanData).reduce(
                  (total, column) =>
                    total +
                    column.tasks.filter((task) => task.isHighPriority).length,
                  0
                )}
              </div>
            </CardContent>
          </Card>
          <Card>
            <CardHeader className="pb-2">
              <CardTitle className="text-sm font-medium">
                Sedang Berlangsung
              </CardTitle>
            </CardHeader>
            <CardContent>
              <div className="text-2xl font-bold text-blue-600">
                {kanbanData["survey-dispatched"].tasks.length +
                  kanbanData["maintenance-scheduled"].tasks.length}
              </div>
            </CardContent>
          </Card>
          <Card>
            <CardHeader className="pb-2">
              <CardTitle className="text-sm font-medium">Selesai</CardTitle>
            </CardHeader>
            <CardContent>
              <div className="text-2xl font-bold text-green-600">
                {kanbanData.completed.tasks.length}
              </div>
            </CardContent>
          </Card>
        </div>
      </div>
    </DndProvider>
  );
}
