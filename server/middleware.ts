export function errorHandler(error: Error, req: Request) {
  console.error("Server error:", error);

  if (process.env.NODE_ENV === "production") {
    return Response.json({ error: "Internal server error" }, { status: 500 });
  }

  return Response.json(
    {
      error: error.message,
      stack: error.stack,
    },
    { status: 500 },
  );
}
