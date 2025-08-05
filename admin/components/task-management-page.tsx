"use client";

import { useState, useCallback } from "react";
import { DndProvider } from "react-dnd";
import { HTML5Backend } from "react-dnd-html5-backend";
import { TouchBackend } from "react-dnd-touch-backend";
import { GripVertical, CheckCircle2, Plus, Edit, Trash2, Save, X } from "lucide-react";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Dialog, DialogContent, DialogDescription, DialogHeader, DialogTitle, DialogTrigger, DialogFooter } from "@/components/ui/dialog";
import { AlertDialog, AlertDialogAction, AlertDialogCancel, AlertDialogContent, AlertDialogDescription, AlertDialogFooter, AlertDialogHeader, AlertDialogTitle } from "@/components/ui/alert-dialog";
import { Badge } from "@/components/ui/badge";
import { Textarea } from "@/components/ui/textarea";
import { useToast } from "@/hooks/use-toast";
import { DraggableTask } from "@/components/draggable-task";
import { DroppableColumn } from "@/components/droppable-column";
import { TaskForm } from "@/components/task-form";

const isTouchDevice = () => {
  if (typeof window === "undefined") return false;
  return "ontouchstart" in window || navigator.maxTouchPoints > 0;
};

// Task interface
interface Task {
  id: string;
  streetName: string;
  priorityScore: number;
  team: string[];
  isHighPriority: boolean;
  status: string;
  assignedDate: string;
  estimatedDuration: string;
  description: string;
  location: string;
}

// Form data interface
interface TaskFormData {
  streetName: string;
  priorityScore: string;
  team: string;
  isHighPriority: boolean;
  estimatedDuration: string;
  description: string;
  location: string;
}

// Team members for selection
const availableTeamMembers = [
  "JD", "SM", "AB", "CD", "EF", "GH", "IJ", "KL", 
  "MN", "OP", "QR", "ST", "UV", "WX", "YZ"
];

// Duration options
const durationOptions = [
  "1 hari", "2 hari", "3 hari", "4 hari", "5 hari",
  "1 minggu", "2 minggu", "1 bulan"
];

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
        description: "Perbaikan jalan utama dengan prioritas tinggi",
        location: "Jakarta Pusat"
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
        description: "Perbaikan lubang kecil di area komersial",
        location: "Jakarta Selatan"
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
        description: "Survei kondisi jalan boulevard utama",
        location: "Jakarta Pusat"
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
        description: "Pemeliharaan rutin area pusat perbelanjaan",
        location: "Jakarta Selatan"
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
        description: "Pemeliharaan terjadwal jalan tol dalam kota",
        location: "Jakarta Selatan"
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
        description: "Perbaikan selesai dengan kualitas baik",
        location: "Jakarta Selatan"
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
        description: "Pemeliharaan area perkantoran selesai",
        location: "Jakarta Selatan"
      },
    ],
  },
};

export function TaskManagementPage() {
  const [kanbanData, setKanbanData] = useState(initialKanbanData);
  const [draggedTask, setDraggedTask] = useState<string | null>(null);
  const [isAutoSaving, setIsAutoSaving] = useState(false);
  const [isCreateDialogOpen, setIsCreateDialogOpen] = useState(false);
  const [isEditDialogOpen, setIsEditDialogOpen] = useState(false);
  const [isDeleteDialogOpen, setIsDeleteDialogOpen] = useState(false);
  const [taskToDelete, setTaskToDelete] = useState<string | null>(null);
  const [editingTask, setEditingTask] = useState<Task | null>(null);
  const [formData, setFormData] = useState<TaskFormData>({
    streetName: "",
    priorityScore: "5.0",
    team: "",
    isHighPriority: false,
    estimatedDuration: "2 hari",
    description: "",
    location: ""
  });
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

  // CRUD Functions
  const resetForm = () => {
    setFormData({
      streetName: "",
      priorityScore: "5.0",
      team: "",
      isHighPriority: false,
      estimatedDuration: "2 hari",
      description: "",
      location: ""
    });
  };

  const generateTaskId = () => {
    const allTasks = Object.values(kanbanData).flatMap(column => column.tasks);
    const maxId = Math.max(...allTasks.map(task => parseInt(task.id.split('-')[1]) || 0));
    return `task-${maxId + 1}`;
  };

  const createTask = useCallback(() => {
    if (!formData.streetName.trim()) {
      toast({
        title: "Error",
        description: "Nama jalan harus diisi",
        variant: "destructive",
      });
      return;
    }

    const newTask: Task = {
      id: generateTaskId(),
      streetName: formData.streetName,
      priorityScore: parseFloat(formData.priorityScore),
      team: formData.team ? formData.team.split(',').map(t => t.trim()) : [],
      isHighPriority: formData.isHighPriority,
      status: "Baru",
      assignedDate: new Date().toISOString().split('T')[0],
      estimatedDuration: formData.estimatedDuration,
      description: formData.description,
      location: formData.location
    };

    setKanbanData(prevData => ({
      ...prevData,
      "new-priority": {
        ...prevData["new-priority"],
        tasks: [...prevData["new-priority"].tasks, newTask]
      }
    }));

    toast({
      title: "Tugas Dibuat",
      description: `Tugas "${formData.streetName}" berhasil dibuat`,
    });

    resetForm();
    setIsCreateDialogOpen(false);
  }, [formData, toast]);

  const editTask = useCallback((task: Task) => {
    setEditingTask(task);
    setFormData({
      streetName: task.streetName,
      priorityScore: task.priorityScore.toString(),
      team: task.team.join(', '),
      isHighPriority: task.isHighPriority,
      estimatedDuration: task.estimatedDuration,
      description: task.description,
      location: task.location
    });
    setIsEditDialogOpen(true);
  }, []);

  const updateTask = useCallback(() => {
    if (!editingTask || !formData.streetName.trim()) {
      toast({
        title: "Error",
        description: "Nama jalan harus diisi",
        variant: "destructive",
      });
      return;
    }

    setKanbanData(prevData => {
      const newData = { ...prevData };
      
      // Find the task in any column
      for (const [columnId, column] of Object.entries(newData)) {
        const taskIndex = column.tasks.findIndex(t => t.id === editingTask.id);
        if (taskIndex !== -1) {
          const updatedTask: Task = {
            ...editingTask,
            streetName: formData.streetName,
            priorityScore: parseFloat(formData.priorityScore),
            team: formData.team ? formData.team.split(',').map(t => t.trim()) : [],
            isHighPriority: formData.isHighPriority,
            estimatedDuration: formData.estimatedDuration,
            description: formData.description,
            location: formData.location
          };
          
          newData[columnId as keyof typeof newData].tasks[taskIndex] = updatedTask;
          break;
        }
      }
      
      return newData;
    });

    toast({
      title: "Tugas Diperbarui",
      description: `Tugas "${formData.streetName}" berhasil diperbarui`,
    });

    resetForm();
    setEditingTask(null);
    setIsEditDialogOpen(false);
  }, [editingTask, formData, toast]);

  const deleteTask = useCallback((taskId: string) => {
    setTaskToDelete(taskId);
    setIsDeleteDialogOpen(true);
  }, []);

  const confirmDeleteTask = useCallback(() => {
    if (!taskToDelete) return;

    setKanbanData(prevData => {
      const newData = { ...prevData };
      
      // Find and remove the task from any column
      for (const [columnId, column] of Object.entries(newData)) {
        const taskIndex = column.tasks.findIndex(t => t.id === taskToDelete);
        if (taskIndex !== -1) {
          const deletedTask = column.tasks[taskIndex];
          newData[columnId as keyof typeof newData].tasks.splice(taskIndex, 1);
          
          toast({
            title: "Tugas Dihapus",
            description: `Tugas "${deletedTask.streetName}" berhasil dihapus`,
          });
          break;
        }
      }
      
      return newData;
    });

    setTaskToDelete(null);
    setIsDeleteDialogOpen(false);
  }, [taskToDelete, toast]);

  const handleFormDataChange = useCallback((newFormData: TaskFormData) => {
    setFormData(newFormData);
  }, []);

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
              Manajemen Tugas
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
            
            {/* Create Task Button */}
            <Dialog open={isCreateDialogOpen} onOpenChange={setIsCreateDialogOpen}>
              <DialogTrigger asChild>
                <Button className="gap-2">
                  <Plus className="h-4 w-4" />
                  Buat Tugas Baru
                </Button>
              </DialogTrigger>
            </Dialog>
            
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
                    onEdit={editTask}
                    onDelete={deleteTask}
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

        {/* Create Task Dialog */}
        <Dialog open={isCreateDialogOpen} onOpenChange={setIsCreateDialogOpen}>
          <DialogContent className="sm:max-w-[600px]">
            <DialogHeader>
              <DialogTitle>Buat Tugas Baru</DialogTitle>
              <DialogDescription>
                Tambahkan tugas perbaikan jalan baru ke dalam sistem
              </DialogDescription>
            </DialogHeader>
            
            <TaskForm
              formData={formData}
              onFormDataChange={handleFormDataChange}
              availableTeamMembers={availableTeamMembers}
              durationOptions={durationOptions}
            />
            
            <DialogFooter>
              <Button variant="outline" onClick={() => setIsCreateDialogOpen(false)}>
                <X className="h-4 w-4 mr-2" />
                Batal
              </Button>
              <Button onClick={createTask}>
                <Save className="h-4 w-4 mr-2" />
                Buat Tugas
              </Button>
            </DialogFooter>
          </DialogContent>
        </Dialog>

        {/* Edit Task Dialog */}
        <Dialog open={isEditDialogOpen} onOpenChange={setIsEditDialogOpen}>
          <DialogContent className="sm:max-w-[600px]">
            <DialogHeader>
              <DialogTitle>Edit Tugas</DialogTitle>
              <DialogDescription>
                Perbarui informasi tugas perbaikan jalan
              </DialogDescription>
            </DialogHeader>
            
            <TaskForm
              formData={formData}
              onFormDataChange={handleFormDataChange}
              availableTeamMembers={availableTeamMembers}
              durationOptions={durationOptions}
            />
            
            <DialogFooter>
              <Button variant="outline" onClick={() => {
                setIsEditDialogOpen(false);
                setEditingTask(null);
                resetForm();
              }}>
                <X className="h-4 w-4 mr-2" />
                Batal
              </Button>
              <Button onClick={updateTask}>
                <Save className="h-4 w-4 mr-2" />
                Simpan Perubahan
              </Button>
            </DialogFooter>
          </DialogContent>
        </Dialog>

        {/* Delete Confirmation Dialog */}
        <AlertDialog open={isDeleteDialogOpen} onOpenChange={setIsDeleteDialogOpen}>
          <AlertDialogContent>
            <AlertDialogHeader>
              <AlertDialogTitle>Hapus Tugas</AlertDialogTitle>
              <AlertDialogDescription>
                Apakah Anda yakin ingin menghapus tugas ini? Tindakan ini tidak dapat dibatalkan.
              </AlertDialogDescription>
            </AlertDialogHeader>
            <AlertDialogFooter>
              <AlertDialogCancel onClick={() => {
                setTaskToDelete(null);
                setIsDeleteDialogOpen(false);
              }}>
                Batal
              </AlertDialogCancel>
              <AlertDialogAction onClick={confirmDeleteTask} className="bg-destructive text-destructive-foreground hover:bg-destructive/90">
                Hapus
              </AlertDialogAction>
            </AlertDialogFooter>
          </AlertDialogContent>
        </AlertDialog>
      </div>
    </DndProvider>
  );
}
