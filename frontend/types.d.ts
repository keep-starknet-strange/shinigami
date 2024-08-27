export interface StackItem {
    id: number;
    value: string;
}
  
export interface StackVisualizerProps {
    stackContent: StackItem[];
}