
import { differenceInMinutes, differenceInHours, differenceInDays } from 'date-fns';

export function delay(time) {
  return new Promise(resolve => setTimeout(resolve, time));
}

export const shuffle = (array) => {
  for (let i = array.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [array[i], array[j]] = [array[j], array[i]];
  }

  return array;
};

export function uniquefy(arr, field) {
  const seen = {};

  return arr.filter((item) => {
    if (!seen[item[field]]) {
      seen[item[field]] = true;
      return true;
    }
    return false;
  });
}

export function ellipseAddress(address, start, end) {
  return `${address.slice(0, start)}...${address.slice(-end)}`.toUpperCase();
}

export function formatNumber(num) {
  if (Math.abs(num) >= 1000000) {
    return parseFloat((num / 1000000).toFixed(1)) + "m";
  } else if (Math.abs(num) >= 1000) {
    return parseFloat((num / 1000).toFixed(1)) + "k";
  } else {
    return Math.floor(num);
  }
}

export function calculateDistance(x1, y1, x2, y2) {
  var deltaX = x2 - x1;
  var deltaY = y2 - y1;
  return Math.sqrt(deltaX * deltaX + deltaY * deltaY);
}

export function getNodeStatus(map, node) {
  if ((node.nodeId === map[0].nodeId && map[0].status === 0) || map.find(_node => node.parents.includes(_node.nodeId) && _node.status !== 0 &&
    !map.find(_node => _node.status !== 0 && _node.parents.find(parent => node.parents.includes(parent))))) {
    return true
  }

  return false
}

export function normalise(value, max) {
  return Math.min(100, (value * 100) / max)
}

export function formatTimeUntil(timestamp) {
  if (!timestamp) return ''

  const now = new Date();
  const target = new Date(timestamp * 1000);

  // Get total differences
  const totalMinutes = differenceInMinutes(target, now);
  const totalHours = differenceInHours(target, now);
  const totalDays = differenceInDays(target, now);

  // Break it down
  const days = totalDays;
  const hours = totalHours - (days * 24);
  const minutes = totalMinutes - (totalHours * 60);

  return `${days}d ${hours}h ${minutes}m`;
}

