const pluralize = (input, singular, irregularPlural) => {
  const plural = irregularPlural || `${singular}s`;
  return input === 1 ? singular : plural;
};
const minutesForHumans = minutes => {
  const hours = Math.floor(minutes / 60);
  const remainder = Math.round(minutes % 60);
  return `${hours} ${pluralize(hours, "hour")} ${remainder} ${pluralize(minutes, "minute")}`;
};
export { pluralize, minutesForHumans };
