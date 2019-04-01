import React from "react";

export default ({ count, singular, plural }) => {
  const suffix = count => (count === 1 ? "" : "s");
  const inflected = () => {
    const isPlural = count !== 1;
    let inflected = singular;
    if (isPlural) {
      inflected = plural || singular + suffix();
    }
    return inflected;
  };
  return <span>{inflected()}</span>;
};