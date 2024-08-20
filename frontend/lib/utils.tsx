export default function clsx(...classes: (string | undefined)[]) {
    return classes.filter(Boolean).join(' ');
}