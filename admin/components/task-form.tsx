"use client";

import { Label } from "@/components/ui/label";
import { Input } from "@/components/ui/input";
import { Textarea } from "@/components/ui/textarea";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Switch } from "@/components/ui/switch";

interface TaskFormData {
  streetName: string;
  priorityScore: string;
  team: string;
  isHighPriority: boolean;
  estimatedDuration: string;
  description: string;
  location: string;
}

interface TaskFormProps {
  formData: TaskFormData;
  onFormDataChange: (data: TaskFormData) => void;
  availableTeamMembers: string[];
  durationOptions: string[];
}

export function TaskForm({ formData, onFormDataChange, availableTeamMembers, durationOptions }: TaskFormProps) {
  const updateField = (field: keyof TaskFormData, value: string | boolean) => {
    onFormDataChange({
      ...formData,
      [field]: value
    });
  };

  return (
    <div className="space-y-4">
      <div className="grid grid-cols-2 gap-4">
        <div className="space-y-2">
          <Label htmlFor="streetName">Nama Jalan *</Label>
          <Input
            id="streetName"
            placeholder="Contoh: Jl. Sudirman"
            value={formData.streetName}
            onChange={(e) => updateField('streetName', e.target.value)}
            className={!formData.streetName.trim() ? "border-destructive" : ""}
          />
          {!formData.streetName.trim() && (
            <p className="text-xs text-destructive">Nama jalan harus diisi</p>
          )}
        </div>
        
        <div className="space-y-2">
          <Label htmlFor="location">Lokasi</Label>
          <Input
            id="location"
            placeholder="Contoh: Jakarta Pusat"
            value={formData.location}
            onChange={(e) => updateField('location', e.target.value)}
          />
        </div>
      </div>

      <div className="grid grid-cols-2 gap-4">
        <div className="space-y-2">
          <Label htmlFor="priorityScore">Skor Prioritas (1-10)</Label>
          <Input
            id="priorityScore"
            type="number"
            min="1"
            max="10"
            step="0.1"
            value={formData.priorityScore}
            onChange={(e) => updateField('priorityScore', e.target.value)}
          />
          <p className="text-xs text-muted-foreground">
            Skor yang lebih tinggi menunjukkan prioritas yang lebih tinggi
          </p>
        </div>
        
        <div className="space-y-2">
          <Label htmlFor="estimatedDuration">Estimasi Durasi</Label>
          <Select value={formData.estimatedDuration} onValueChange={(value) => updateField('estimatedDuration', value)}>
            <SelectTrigger>
              <SelectValue />
            </SelectTrigger>
            <SelectContent>
              {durationOptions.map((duration) => (
                <SelectItem key={duration} value={duration}>
                  {duration}
                </SelectItem>
              ))}
            </SelectContent>
          </Select>
        </div>
      </div>

      <div className="space-y-2">
        <Label htmlFor="team">Tim (pisahkan dengan koma)</Label>
        <Input
          id="team"
          placeholder="Contoh: JD, SM, AB"
          value={formData.team}
          onChange={(e) => updateField('team', e.target.value)}
        />
        <p className="text-xs text-muted-foreground">
          Tim tersedia: {availableTeamMembers.join(', ')}
        </p>
      </div>

      <div className="space-y-2">
        <Label htmlFor="description">Deskripsi</Label>
        <Textarea
          id="description"
          placeholder="Deskripsi detail tentang tugas..."
          value={formData.description}
          onChange={(e) => updateField('description', e.target.value)}
          rows={3}
        />
      </div>

      <div className="flex items-center justify-between p-4 bg-muted/50 rounded-lg">
        <div className="flex items-center space-x-2">
          <Switch
            id="isHighPriority"
            checked={formData.isHighPriority}
            onCheckedChange={(checked) => updateField('isHighPriority', checked)}
          />
          <Label htmlFor="isHighPriority">Prioritas Tinggi</Label>
        </div>
        {formData.isHighPriority && (
          <div className="text-xs text-orange-600 font-medium">
            ⚠️ Tugas akan ditandai sebagai prioritas tinggi
          </div>
        )}
      </div>
    </div>
  );
}
