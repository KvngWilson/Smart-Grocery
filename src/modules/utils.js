export const maxItems = 50;

export function checkItemLimit(list) {
    if (list.length >= maxItems) {
        throw new Error('Item limit reached');
    }
    return true;
}

