import { XanaduLink } from '../src/xanadu-link.ts';
import { DraggableBox } from '../src/draggable-box.ts';

console.log('xanadu!')

class DraggableDocument extends DraggableBox {
    static tagName = 'draggable-document';

    onMouseDrag({ movementX, movementY }) {
        const { left, top } = getComputedStyle(this);
        let leftValue = parseInt(left);
        let topValue = parseInt(top) + movementY;
        this.style.left = `${leftValue + movementX}px`;
        if (this.offsetHeight < document.documentElement.clientHeight) {
            this.style.top = `${topValue}px`;
        }
    }
}

DraggableDocument.register();

class AnimatedXanaduLink extends XanaduLink {
    sourceAnimation = null;
    targetAnimation = null;

    observeSource() {
        super.observeSource();

        this.sourceAnimation = this.animate(
            [
                { opacity: 0.3, offset: 0 },
                { opacity: 1, offset: 0.1 },
                { opacity: 1, offset: 0.9 },
                { opacity: 0.3, offset: 1 },
            ],
            {
                timeline: new ViewTimeline({
                    subject: this.sourceElement,
                }),
                rangeStart: 'entry 0%',
                rangeEnd: 'exit 100%',
            }
        );
    }

    unobserveSource() {
        super.unobserveSource();

        this.sourceAnimation?.cancel();
        this.sourceAnimation = null;
    }

    observeTarget() {
        super.observeTarget();

        this.targetAnimation = this.animate(
            [
                { opacity: 0.3, offset: 0 },
                { opacity: 1, offset: 0.1 },
                { opacity: 1, offset: 0.9 },
                { opacity: 0.3, offset: 1 },
            ],
            {
                timeline: new ViewTimeline({
                    subject: this.targetElement,
                }),
                rangeStart: 'entry 0%',
                rangeEnd: 'exit 100%',
            }
        );
    }

    unobserveTarget() {
        super.unobserveTarget();

        this.targetAnimation?.cancel();
        this.targetAnimation = null;
    }
}

AnimatedXanaduLink.register();