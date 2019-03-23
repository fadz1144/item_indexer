const API_BASE = `${process.env.PUBLIC_URL}/../api/`;
const API_SUFFIX = ".json";

export default path => {
  return API_BASE + path + API_SUFFIX;
};
