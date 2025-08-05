"use client"

import type React from "react"

import { useRef } from "react"
import { useDrop } from "react-dnd"
import { Badge } from "@/components/ui/badge"

interface DroppableColumnProps {
  columnId: string
  title: string
  taskCount: number
  children: React.ReactNode
  onMoveTask: (taskId: string, sourceColumnId: string, targetColumnId: string, targetIndex: number) => void
}

const ItemType = "TASK"

export function DroppableColumn({ columnId, title, taskCount, children, onMoveTask }: DroppableColumnProps) {
  const ref = useRef<HTMLDivElement>(null)

  const [{ isOver, canDrop }, drop] = useDrop({
    accept: ItemType,
    drop: (item: { id: string; index: number; columnId: string }) => {
      if (item.columnId !== columnId) {
        onMoveTask(item.id, item.columnId, columnId, 0)
      }
    },
    collect: (monitor) => ({
      isOver: monitor.isOver(),
      canDrop: monitor.canDrop(),
    }),
  })

  drop(ref)

  return (
    <div
      ref={ref}
      className={`space-y-4 transition-all duration-200 ${
        isOver && canDrop ? "bg-primary/5 rounded-lg p-2 border-2 border-dashed border-primary" : ""
      }`}
    >
      <div className="flex items-center justify-between">
        <h3 className="font-semibold text-sm text-muted-foreground uppercase tracking-wide">{title}</h3>
        <Badge variant="secondary" className={isOver && canDrop ? "bg-primary text-primary-foreground" : ""}>
          {taskCount}
        </Badge>
      </div>
      {children}
      {isOver && canDrop && (
        <div className="flex items-center justify-center h-12 border-2 border-dashed border-primary rounded-lg bg-primary/10">
          <p className="text-sm text-primary font-medium">Drop task here</p>
        </div>
      )}
    </div>
  )
}
