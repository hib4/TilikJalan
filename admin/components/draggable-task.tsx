"use client";

import { useRef, useEffect, useState } from "react";
import { useDrag, useDrop } from "react-dnd";
import {
  Users,
  GripVertical,
  Clock,
  Calendar,
  Edit,
  Trash2,
  MoreVertical,
  MapPin,
  FileText,
} from "lucide-react";
import { Avatar, AvatarFallback } from "@/components/ui/avatar";
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
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu";

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

interface DraggableTaskProps {
  task: Task;
  index: number;
  columnId: string;
  isDragging: boolean;
  onDragStart: (taskId: string) => void;
  onDragEnd: () => void;
  onEdit?: (task: Task) => void;
  onDelete?: (taskId: string) => void;
}

const ItemType = "TASK";

export function DraggableTask({
  task,
  index,
  columnId,
  isDragging,
  onDragStart,
  onDragEnd,
  onEdit,
  onDelete,
}: DraggableTaskProps) {
  const ref = useRef<HTMLDivElement>(null);
  const [isAnimating, setIsAnimating] = useState(false);

  const [{ isDragging: dragState }, drag, preview] = useDrag({
    type: ItemType,
    item: () => {
      onDragStart(task.id);
      return { id: task.id, index, columnId };
    },
    collect: (monitor) => ({
      isDragging: monitor.isDragging(),
    }),
    end: () => {
      onDragEnd();
      // Trigger reset animation
      setIsAnimating(true);
      setTimeout(() => setIsAnimating(false), 300);
    },
  });

  const [{ isOver, canDrop }, drop] = useDrop({
    accept: ItemType,
    hover: (draggedItem: { id: string; index: number; columnId: string }) => {
      if (!ref.current) return;
      if (draggedItem.id === task.id) return;

      const dragIndex = draggedItem.index;
      const hoverIndex = index;
      const dragColumnId = draggedItem.columnId;
      const hoverColumnId = columnId;

      // Don't replace items with themselves
      if (dragIndex === hoverIndex && dragColumnId === hoverColumnId) return;

      // Update the dragged item's position
      draggedItem.index = hoverIndex;
      draggedItem.columnId = hoverColumnId;
    },
    collect: (monitor) => ({
      isOver: monitor.isOver(),
      canDrop: monitor.canDrop(),
    }),
  });

  // Connect drag and drop refs
  drag(drop(ref));

  // Reset transform when drag ends
  useEffect(() => {
    if (!dragState && ref.current) {
      ref.current.style.transform = "";
    }
  }, [dragState]);

  // Dynamic styles based on drag state
  const getCardStyles = () => {
    if (dragState) {
      return {
        opacity: 0.7,
        transform: "rotate(3deg) scale(1.02)",
        zIndex: 1000,
        transition: "none",
      };
    }

    if (isAnimating) {
      return {
        transform: "rotate(0deg) scale(1)",
        transition: "all 0.3s cubic-bezier(0.4, 0, 0.2, 1)",
      };
    }

    return {
      transform: "rotate(0deg) scale(1)",
      transition: "all 0.2s ease-in-out",
    };
  };

  return (
    <Card
      ref={ref}
      className={`
        cursor-move relative overflow-hidden
        ${task.isHighPriority ? "border-l-4 border-l-orange-500" : ""}
        ${isOver && canDrop ? "ring-2 ring-primary/50 bg-primary/5" : ""}
        ${dragState ? "shadow-2xl" : "hover:shadow-md"}
        transition-shadow duration-200
      `}
      style={getCardStyles()}
    >
      <CardHeader className="pb-3 pr-2">
        <div className="flex items-start gap-2">
          <GripVertical className="h-4 w-4 text-muted-foreground hover:text-primary transition-colors shrink-0 mt-0.5" />
          <div className="flex-1 min-w-0">
            <CardTitle className="text-sm font-medium leading-tight truncate pr-2">
              {task.streetName}
            </CardTitle>
            <CardDescription className="text-xs mt-1 truncate">
              Priority Score: {task.priorityScore}
            </CardDescription>
          </div>
          {task.isHighPriority && (
            <Badge
              variant="destructive"
              className="text-xs shrink-0 px-1.5 py-0.5 h-auto whitespace-nowrap"
            >
              High Priority
            </Badge>
          )}

          {/* Action Menu */}
          {(onEdit || onDelete) && (
            <DropdownMenu>
              <DropdownMenuTrigger asChild>
                <Button
                  variant="ghost"
                  size="sm"
                  className="h-6 w-6 p-0 shrink-0"
                >
                  <MoreVertical className="h-3 w-3" />
                </Button>
              </DropdownMenuTrigger>
              <DropdownMenuContent align="end" className="w-40">
                {onEdit && (
                  <DropdownMenuItem onClick={() => onEdit(task)}>
                    <Edit className="h-3 w-3 mr-2" />
                    Edit
                  </DropdownMenuItem>
                )}
                {onDelete && (
                  <DropdownMenuItem
                    onClick={() => onDelete(task.id)}
                    className="text-destructive focus:text-destructive"
                  >
                    <Trash2 className="h-3 w-3 mr-2" />
                    Hapus
                  </DropdownMenuItem>
                )}
              </DropdownMenuContent>
            </DropdownMenu>
          )}
        </div>
      </CardHeader>

      <CardContent className="pt-0 space-y-3">
        {/* Team Assignment */}
        <div className="flex items-center justify-between gap-2">
          <div className="flex items-center gap-2 min-w-0 flex-1">
            <Users className="h-4 w-4 text-muted-foreground shrink-0" />
            <div className="flex -space-x-1 shrink-0">
              {task.team.slice(0, 3).map((member, index) => (
                <Avatar
                  key={index}
                  className="h-5 w-5 border-2 border-background"
                >
                  <AvatarFallback className="text-xs font-medium">
                    {member}
                  </AvatarFallback>
                </Avatar>
              ))}
              {task.team.length > 3 && (
                <div className="h-5 w-5 rounded-full bg-muted border-2 border-background flex items-center justify-center">
                  <span className="text-xs font-medium text-muted-foreground">
                    +{task.team.length - 3}
                  </span>
                </div>
              )}
            </div>
          </div>
          <Badge
            variant="outline"
            className="text-xs shrink-0 px-1.5 py-0.5 h-auto"
          >
            {task.status}
          </Badge>
        </div>

        {/* Task Details */}
        <div className="grid grid-cols-1 gap-2 text-xs text-muted-foreground">
          {task.location && (
            <div className="flex items-center gap-1.5 min-w-0">
              <MapPin className="h-3 w-3 shrink-0" />
              <span className="truncate">{task.location}</span>
            </div>
          )}
          {task.description && (
            <div className="flex items-start gap-1.5 min-w-0">
              <FileText className="h-3 w-3 shrink-0 mt-0.5" />
              <span className="text-xs line-clamp-2">{task.description}</span>
            </div>
          )}
          <div className="flex items-center gap-1.5 min-w-0">
            <Calendar className="h-3 w-3 shrink-0" />
            <span className="truncate">
              Assigned: {new Date(task.assignedDate).toLocaleDateString()}
            </span>
          </div>
          <div className="flex items-center gap-1.5 min-w-0">
            <Clock className="h-3 w-3 shrink-0" />
            <span className="truncate">Duration: {task.estimatedDuration}</span>
          </div>
        </div>

        {/* Drag Indicator Overlay */}
        {dragState && (
          <div className="absolute inset-0 bg-primary/10 backdrop-blur-sm rounded-lg flex items-center justify-center">
            <div className="bg-primary text-primary-foreground px-3 py-1.5 rounded-md text-xs font-medium shadow-lg">
              Moving Task...
            </div>
          </div>
        )}
      </CardContent>
    </Card>
  );
}
